extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Handle the differents fighting phases (NORMAL/ACCELERATED/FINISHED) for every other FightingManager

# ============================== Signals ==============================

signal all_fights_are_over()

# ============================== Private variables ==============================

var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]


# ====== SERVER ONLY

var _players_running_playback: Array[Player]

# ============================== Node base functions ==============================

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public functions ==============================

func clear() -> void:
	_fighting_managers.clear()
	_current_active_fighting_managers.clear()
	_players_running_playback.clear()


func start() -> void:
	if not multiplayer.is_server(): return
	_players_running_playback = PlayerManager.get_human_players().values().duplicate()


func register_fighting_manager(fighting_manager: FightingManager):
	if _fighting_managers.has(fighting_manager):
		printerr("FightingManager[", fighting_manager, "] already registered !")
		return
	
	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_ready_to_be_started.connect(_on_fighting_manager_fight_is_ready_to_be_started)
	fighting_manager.fight_is_over.connect(_fighting_manager_fighting_is_over)


func unregister_fighting_manager(fighting_manager: FightingManager):
	if not _fighting_managers.has(fighting_manager):
		printerr("FightingManager[", fighting_manager, "] is not registered !")
		return
	
	_fighting_managers.erase(fighting_manager)
	fighting_manager.fight_is_over.disconnect(_fighting_manager_fighting_is_over)

# ============================== State changed callbacks ==============================

func _on_game_manager_game_state_changed(new_state) -> void:
	if new_state == Game.GameState.FIGHTING_CELEBRATING:
		print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: FINISHED")
		# START the watchdog timer on server
		if multiplayer.is_server(): _wait_for_all_players_to_finish_playback()
		else: _notice_playback_is_over.rpc_id(1)


signal _all_players_playback_finished()
func _wait_for_all_players_to_finish_playback() -> void:
	if not multiplayer.is_server(): return
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Waiting for clients to finish their playback")
	if GameManager.game_type != GameManager.GameType.SOLO and not _players_running_playback.is_empty():
		await _all_players_playback_finished
	_finish_all_fights.rpc()


@rpc("authority", "call_local")
func _finish_all_fights() -> void:
	all_fights_are_over.emit()
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Finishing GFM, returning to main game loop")
	_players_running_playback.clear()


@rpc("any_peer", "call_remote")
func _notice_playback_is_over() -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: player(", peer_id, ") finished its playback")
	if _players_running_playback.has(PlayerManager.players[peer_id]):
		_players_running_playback.erase(PlayerManager.players[peer_id])
	else:
		printerr("[", multiplayer.get_unique_id(), "] GlobalFightingManager: player(", peer_id, ") notice playback is finished but is not listed")
	
	if _players_running_playback.is_empty():
		_all_players_playback_finished.emit()

# ============================== FightingManager callbacks ==============================

func _fighting_manager_fighting_is_over(fighting_manager: FightingManager, _winner_teams_order: Array[int]) -> void:
	if not _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: An unexpected FightingArea signal a fight is over [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.erase(fighting_manager)
	if _current_active_fighting_managers.is_empty():
		GameManager.update_game_state(Game.GameState.FIGHTING_CELEBRATING)


func _on_fighting_manager_fight_is_ready_to_be_started(fighting_manager: FightingManager) -> void:
	if _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: A fight is starting more than once at the same time on the same FightingArea [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.append(fighting_manager)



















 
