class_name BattleReader
extends Node

# [CLIENT ONLY]
# Rejoue le BattleLog du serveur : le client ne simule pas le combat, il consomme
# les logs (mêmes clés string que le BattleWriter) et applique les effets déjà
# résolus. Les dégâts/soins passent par la couche `apply` (mutation pure, valeur
# pré-résolue, zéro RNG) ; les auto-attaques rejouent un swing visuel only.

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _entity_signal_relay: EntitySignalRelay

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary] = []
var _current_index: int = 0
var _is_playing: bool = false
var simulated_delay_ms: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	GlobalFightingManager.fighting_phase_state_changed.connect(_on_gfm_fighting_phase_state_changed)
	GlobalFightingManager.all_fights_are_over.connect(_on_gfm_all_fights_are_over)


func _process(_delta: float) -> void:
	# Le serveur (et le solo, où is_server() ment) simule + écrit, il ne rejoue rien.
	# Gardé ici (et non en _ready) car le rôle réseau n'est établi qu'au moment du combat,
	# alors que ce node existe dès le chargement de scène (OfflineMultiplayerPeer → is_server true).
	if multiplayer.is_server(): return
	if not _is_playing: return
	# Drain FIFO : on applique tous les logs reçus, dans l'ordre. La latence réseau
	# + simulated_delay_ms (dans add_log) suffisent à étaler le playback.
	while _current_index < _battle_logs.size():
		_apply_log(_battle_logs[_current_index])
		_current_index += 1

# ============================== Public function ==============================

func add_log(logs: Array[Dictionary]) -> void:
	if simulated_delay_ms > 0:
		await get_tree().create_timer(simulated_delay_ms / 1000.0).timeout
	_battle_logs += logs


func get_all_logs() -> Array[Dictionary]:
	return _battle_logs


func _on_gfm_fighting_phase_state_changed(state: GlobalFightingManager.FightingPhaseState) -> void:
	match state:
		GlobalFightingManager.FightingPhaseState.NORMAL:
			_start_playback()
		# CELEBRATION : on NE stoppe PAS le playback. Le serveur flush ses derniers logs
		# (les kills de fin de combat) à SON passage en CELEBRATION, qui arrive APRÈS le
		# nôtre. Il faut continuer à drainer jusqu'à all_fights_are_over, sinon la fin du
		# combat — morts comprises — n'est jamais rejouée et le client fige des survivants.


func _on_gfm_all_fights_are_over() -> void:
	_is_playing = false
	_battle_logs.clear()
	_current_index = 0

# ============================== Private function ==============================

func _start_playback() -> void:
	_current_index = 0
	_is_playing = true


func _apply_log(battle_log: Dictionary) -> void:
	match String(battle_log.get("type", "")):
		"auto_attack": _apply_auto_attack(battle_log)
		"action_done": _apply_action_done(battle_log)
		"action_received": _apply_interaction_received(battle_log)
		_: pass # types non rejoués dans cette passe (projectile/entity_spawned/spell…)

# ============================== Logs applied ==============================

func _apply_auto_attack(battle_log: Dictionary) -> void:
	var source: Entity = _entity_signal_relay.get_entity(battle_log.get("source", -1))
	var target: Entity = _entity_signal_relay.get_entity(battle_log.get("target", -1))
	if source == null or target == null: return
	Verbose.trace("Auto-attack: " + str(source.uid) + "->" + str(target.uid), Verbose.Category.BATTLE_READER)
	source.auto_attack.execute_auto_attack(target)


func _apply_action_done(battle_log: Dictionary) -> void:
	var source: Entity = _entity_signal_relay.get_entity(battle_log.get("source", -1))
	var target: Entity = _entity_signal_relay.get_entity(battle_log.get("target", -1))
	if source == null or target == null: return

	var action_type: Utils.ActionType = _parse_action_type(battle_log)
	if action_type == -1: return
	var action_id: StringName = battle_log.get("id", &"Unknown action")
	var value: float = battle_log.get("value", 0.0)
	var is_critical: bool = battle_log.get("critical", false)

	# Re-émet le signal pour que FamilyManagers & co réagissent côté client.
	source.action_done.emit(target, action_type, action_id, value, is_critical)


func _apply_interaction_received(battle_log: Dictionary) -> void:
	var receiver: Entity = _entity_signal_relay.get_entity(battle_log.get("receiver", -1))
	if receiver == null: return

	var source_id: int = battle_log.get("source", -1)
	var source: Entity = _entity_signal_relay.get_entity(source_id) if source_id != -1 else null

	var action_type: Utils.ActionType = _parse_action_type(battle_log)
	if action_type == -1: return
	var action_id: StringName = battle_log.get("id", &"Unknown action")
	var value: float = battle_log.get("value", 0.0)
	var is_critical: bool = battle_log.get("critical", false)

	Verbose.trace("Interaction received: " + str(source_id) + "->" + str(receiver.uid) + " | " \
			+ str(Utils.ActionType.keys()[action_type]) + " | " + str(action_id) + " | " \
			+ str(value) + " | " + str(is_critical), Verbose.Category.BATTLE_READER)
	_map_interaction(receiver, source, action_type, action_id, value, is_critical)

# ============================== Action/Interaction Mapping ==============================

func _map_interaction(receiver: Entity, source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	match action_type:
		# Dégâts / soins : valeur déjà résolue par le serveur → apply (mutation pure).
		Utils.ActionType.DAMAGE_PHYSICAL: receiver.damage.apply(value, Utils.ActionType.DAMAGE_PHYSICAL, is_critical, action_id, source)
		Utils.ActionType.DAMAGE_MAGICAL: receiver.damage.apply(value, Utils.ActionType.DAMAGE_MAGICAL, is_critical, action_id, source)
		Utils.ActionType.DAMAGE_POISON: receiver.damage.apply(value, Utils.ActionType.DAMAGE_POISON, is_critical, action_id, source)
		Utils.ActionType.DAMAGE_PURE: receiver.damage.apply(value, Utils.ActionType.DAMAGE_PURE, is_critical, action_id, source)
		Utils.ActionType.UTILITY_HEAL: receiver.heal.apply(value, is_critical, action_id, source)
		# Altérations : hors périmètre de cette passe (pass dédiée). take_* sur le client
		# saute la résolution serveur (gardée par is_server) → applique sans re-roll.
		Utils.ActionType.UTILITY_CLEANSE: receiver.alterations.take_cleanse(value, is_critical, action_id, source)
		Utils.ActionType.UTILITY_DISPELL: receiver.alterations.take_dispell(value, is_critical, action_id, source)
		Utils.ActionType.STACK_SHIELD: receiver.alterations.take_stack(value, Alteration.Type.SHIELD, is_critical, action_id, source)
		Utils.ActionType.STACK_IGNITE: receiver.alterations.take_stack(value, Alteration.Type.IGNITE, is_critical, action_id, source)
		Utils.ActionType.STACK_POISON: receiver.alterations.take_stack(value, Alteration.Type.POISON, is_critical, action_id, source)
		Utils.ActionType.STACK_REGEN: receiver.alterations.take_stack(value, Alteration.Type.REGEN, is_critical, action_id, source)
		Utils.ActionType.STACK_NECROSIS: receiver.alterations.take_stack(value, Alteration.Type.NECROSIS, is_critical, action_id, source)
		Utils.ActionType.STATUS_STUN: receiver.alterations.take_status(Alteration.Type.STUN, value, action_id, source)
		Utils.ActionType.STATUS_TAUNT: receiver.alterations.take_status(Alteration.Type.TAUNT, value, action_id, source)
		Utils.ActionType.STATUS_SILENCE: receiver.alterations.take_status(Alteration.Type.SILENCE, value, action_id, source)
		Utils.ActionType.STATUS_INVULNERABLE: receiver.alterations.take_status(Alteration.Type.INVULNERABLE, value, action_id, source)
		Utils.ActionType.STATUS_UNTARGETABLE: receiver.alterations.take_status(Alteration.Type.UNTARGETABLE, value, action_id, source)


# Reconvertit la valeur string du log ("DAMAGE_PHYSICAL") en Utils.ActionType.
# Renvoie -1 si la clé est inconnue (log malformé).
func _parse_action_type(battle_log: Dictionary) -> Utils.ActionType:
	var key: String = String(battle_log.get("action_type", ""))
	if not Utils.ActionType.keys().has(key):
		Verbose.warn("Unknown action_type in log | " + key, Verbose.Category.BATTLE_READER)
		return -1
	return Utils.ActionType[key]
