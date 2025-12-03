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
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Callbacks functions ============================== [SERVER ONLY]

func _on_synchronizer_timer_timeout() -> void:
	var new_logs: Array[Dictionary] = _battle_writer.get_current_logs()
	if not new_logs.is_empty():
		Verbose.debug("Sending battle logs | " + str(new_logs.size()), Verbose.Category.BATTLE_SYNC)
		_sync_battle_log.rpc(new_logs)


func _on_game_manager_game_state_changed(state: Game.GameState) -> void:
	match state:
		Game.GameState.BUYING:
			_battle_logs.clear()
		Game.GameState.FIGHTING_NORMAL:
			if multiplayer.is_server():
				_synchronizer_timer.start()
		Game.GameState.FIGHTING_CELEBRATING: # TODO Si erreur de synchro sur les derniers event d'un combat, c'est surement une race ici
			if multiplayer.is_server():
				_synchronizer_timer.stop()
				var new_logs: Array[Dictionary] = _battle_writer.get_current_logs()
				if not new_logs.is_empty():
					_sync_battle_log.rpc(new_logs)

# ============================== Callbacks functions ============================== [CLIENT ONLY]

# ============================== RPC - Synchronizer ==============================

@rpc("authority", "call_remote", "reliable")
func _sync_battle_log(logs: Array[Dictionary]) -> void:
	Verbose.debug("Receiving battle logs | " + str(logs.size()), Verbose.Category.BATTLE_SYNC)
	_battle_logs += logs
	_battle_reader.add_log(logs)
