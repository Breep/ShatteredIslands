class_name BattleLogSynchronizer
extends Node

@export_group("External nodes")
@export var _battle_writer: BattleWriter

@onready var _synchronizer_timer: Timer = %SynchronizerTimer

var _battle_logs: Array[Dictionary]

func _ready() -> void:
	if not multiplayer.is_server(): return
	GlobalFightingManager.state_changed.connect(_on_global_fighting_manager_state_changed)
	_synchronizer_timer.wait_time *= GlobalFightingManager.SERVER_TIME_SCALE # Needs to be relative to the Engine speed up


@rpc("authority", "call_remote", "reliable")
func _sync_battle_log(_log: Array[Dictionary]) -> void:
	print("[", multiplayer.get_unique_id(), "] BattleLogSynchronizer: Receiving ", _log.size(), " logs | ", get_path())
	_battle_logs += _log


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
