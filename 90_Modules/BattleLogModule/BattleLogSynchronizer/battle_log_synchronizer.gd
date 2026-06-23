class_name BattleLogSynchronizer
extends Node

# Transport des BattleLog serveur → clients, avec séquençage absolu pour survivre
# aux déconnexions. Chaque batch porte son index de départ absolu (from_index) dans
# le log complet du combat. Le client n'applique que des batches contigus ; un trou
# (déco) déclenche un request_catchup qui fait renvoyer la tranche manquante.

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _battle_writer: BattleWriter
@export var _battle_reader: BattleReader

# ============================== Local nodes ==============================

@onready var _synchronizer_timer: Timer = %SynchronizerTimer

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary] = [] # [CLIENT ONLY] buffer de debug
# [CLIENT ONLY] Nombre de logs appliqués de façon contiguë = index absolu attendu.
var _received_count: int = 0
# [CLIENT ONLY] Anti-spam : une demande de rattrapage est déjà en vol.
var _catchup_in_flight: bool = false

# ============================== Public functions ==============================

func set_sync_period(period: float) -> void:
	_synchronizer_timer.wait_time = period

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)

# ============================== Callbacks functions ============================== [SERVER ONLY]

func _on_synchronizer_timer_timeout() -> void:
	_broadcast_new_logs()


func _on_gfm_fighting_phase_state_changed(state: GlobalFightingManager.FightingPhaseState) -> void:
	match state:
		GlobalFightingManager.FightingPhaseState.NORMAL:
			if multiplayer.is_server():
				_synchronizer_timer.start()
			else:
				# Nouveau combat : on repart de zéro côté séquençage client.
				_received_count = 0
				_catchup_in_flight = false
				_battle_logs.clear()
		GlobalFightingManager.FightingPhaseState.CELEBRATION:
			if multiplayer.is_server():
				_synchronizer_timer.stop()
				_broadcast_new_logs() # flush final (kills de fin de combat)
			_battle_logs.clear()
			_received_count = 0
			_catchup_in_flight = false

# ============================== Private functions ============================== [SERVER ONLY]

func _broadcast_new_logs() -> void:
	var from_index: int = _battle_writer.get_sent_count()
	var new_logs: Array[Dictionary] = _battle_writer.get_current_logs()
	if new_logs.is_empty(): return
	Verbose.debug("Sending battle logs | %d (from %d)" % [new_logs.size(), from_index], Verbose.Category.BATTLE_SYNC)
	_sync_battle_log.rpc(from_index, new_logs)

# ============================== RPC - Synchronizer ==============================

# [SERVER → CLIENT] Diffuse (ou rattrape) un batch de logs étiqueté de son index
# absolu de départ. Le client applique en ordre strict.
@rpc("authority", "call_remote", "reliable")
func _sync_battle_log(from_index: int, logs: Array[Dictionary]) -> void:
	if from_index > _received_count:
		# Trou (logs perdus pendant une déco) : on jette ce batch et on demande la
		# tranche manquante depuis notre position. Réappliqué proprement au retour.
		Verbose.debug("Gap detected | expected %d, got %d → catch-up" % [_received_count, from_index], Verbose.Category.BATTLE_SYNC)
		if not _catchup_in_flight:
			_catchup_in_flight = true
			_request_catchup.rpc_id(1, _received_count)
		return

	var overlap: int = _received_count - from_index
	if overlap >= logs.size():
		return # entièrement déjà reçu (doublon de rattrapage / broadcast)

	var fresh: Array[Dictionary] = logs.slice(overlap)
	_received_count += fresh.size()
	_catchup_in_flight = false # progression contiguë → on autorise de futures demandes
	_battle_logs += fresh
	_battle_reader.add_log(fresh)


# [CLIENT → SERVER] Demande le renvoi de tout le log à partir de from_index, adressé
# uniquement au demandeur. Le BattleWriter conserve l'intégralité du combat.
@rpc("any_peer", "call_remote", "reliable")
func _request_catchup(from_index: int) -> void:
	if not multiplayer.is_server(): return
	var sender: int = multiplayer.get_remote_sender_id()
	var start: int = max(0, from_index)
	var logs: Array[Dictionary] = _battle_writer.get_all_logs().slice(start)
	if logs.is_empty(): return
	Verbose.debug("Catch-up to peer %d | %d logs (from %d)" % [sender, logs.size(), start], Verbose.Category.BATTLE_SYNC)
	_sync_battle_log.rpc_id(sender, start, logs)
