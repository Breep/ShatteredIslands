class_name BattleLogSynchronizer
extends Node

# ============================== Export variables ==============================

@export_group("External nodes")
@export var _battle_writer: BattleWriter
@export var _battle_reader: BattleReader

# ============================== Local nodes ==============================

@onready var _synchronizer_timer: Timer = %SynchronizerTimer

# ============================== Private variables ==============================

var _battle_logs: Array[Dictionary] = [] # [CLIENT ONLY]

# ============================== Node base functions ==============================

func _ready() -> void:
	if multiplayer.is_server():
		GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
		_synchronizer_timer.wait_time *= GlobalFightingManager.SERVER_TIME_SCALE # Needs to be relative to the Engine speed up
	else:
		Events.game_state_changed.connect(_on_events_game_state_changed)

# ============================== Callbacks functions ============================== [SERVER ONLY]

func _on_synchronizer_timer_timeout() -> void:
	var new_logs: Array[Dictionary] = _battle_writer.get_current_logs()
	if not new_logs.is_empty():
		_sync_battle_log.rpc(new_logs)


func _on_global_fighting_manager_state_changed(state: GlobalFightingManager.FightingState) -> void:
	if state == GlobalFightingManager.FightingState.FIGHTING:
		_synchronizer_timer.start()
	elif state == GlobalFightingManager.FightingState.CELEBRATING: # TODO Si erreur de synchro sur les derniers event d'un combat, c'est surement une race ici
		_synchronizer_timer.stop()
		var new_logs: Array[Dictionary] = _battle_writer.get_current_logs()
		if not new_logs.is_empty():
			_sync_battle_log.rpc(new_logs)

# ============================== Callbacks functions ============================== [CLIENT ONLY]

func _on_events_game_state_changed(state: Game.GameState) -> void:
	if state == Game.GameState.BUYING: _battle_logs.clear()

# ============================== RPC - Synchronizer ==============================

@rpc("authority", "call_remote", "reliable")
func _sync_battle_log(logs: Array[Dictionary]) -> void:
	print("[", multiplayer.get_unique_id(), "] BattleLogSynchronizer: Receiving ", logs.size(), " logs | ", get_path())
	_battle_logs += logs
	_battle_reader.add_log(logs)
