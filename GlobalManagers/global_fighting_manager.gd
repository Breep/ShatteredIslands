extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Handle the differents fighting phases (NORMAL/ACCELERATED/FINISHED) for every other FightingManager

# ============================== Signals ==============================

signal all_fights_are_over()

# ============================== Enum ==============================

enum FightingPhaseState {
	UNDEF,
	POSITIONING,
	COUNTDOWN,
	NORMAL,
	ACCELERATED,
	CELEBRATING,
	FINISHED,
}

# ============================== Constants ==============================

const ACCELERATED_FIGHT_TIME_SCALE = 2.0

# ============================== Private variables ==============================

var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]

# /!\ _fighting_phase_state is NOT sync, the server is ahead of time /!\
signal fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState)
var __fighting_phase_state := FightingPhaseState.UNDEF
var _fighting_phase_state: FightingPhaseState:
	get: return __fighting_phase_state
	set(value):
		if __fighting_phase_state == value: return
		__fighting_phase_state = value
		fighting_phase_state_changed.emit(__fighting_phase_state)

var _skip_countdown: bool = false

@onready var _timer := Timer.new()

# ====== SERVER ONLY

var _players_running_playback: Array[Player]

# ============================== Node base functions ==============================

func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)
	fighting_phase_state_changed.connect(_on_fighting_phase_state_changed)
	_timer.autostart = false
	_timer.one_shot = true

# ============================== Public functions ==============================

func clear() -> void:
	_fighting_managers.clear()
	_current_active_fighting_managers.clear()
	_players_running_playback.clear()


func start() -> void:
	Verbose.debug("START", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if __prototyping or GameManager.game_type == GameManager.GameType.SOLO or not multiplayer.is_server():
		_skip_countdown = false
	else:
		_skip_countdown = true
	if multiplayer.is_server():
		_players_running_playback = PlayerManager.get_human_players().values().duplicate()
	_fighting_phase_state = FightingPhaseState.POSITIONING

#region Register/Unregister FightingManager
func register_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("register_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] already registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	
	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_ready_to_be_started.connect(_on_fighting_manager_fight_is_ready_to_be_started)
	fighting_manager.fight_is_over.connect(_fighting_manager_fighting_is_over)


func unregister_fighting_manager(fighting_manager: FightingManager):
	Verbose.trace("unregister_fighting_manager() | " + str(fighting_manager.get_path()), Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if not _fighting_managers.has(fighting_manager):
		Verbose.error("FightingManager[" + str(fighting_manager) + "] is not registered !", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	
	_fighting_managers.erase(fighting_manager)
	fighting_manager.fight_is_over.disconnect(_fighting_manager_fighting_is_over)
#endregion


var __prototyping = false
func _on_timer_timeout() -> void:
	match __fighting_phase_state:
		FightingPhaseState.POSITIONING: # End of POSITIONING State
			if _skip_countdown:
				_fighting_phase_state = FightingPhaseState.NORMAL # Trigger FIGHT directly on server
			else:
				_fighting_phase_state = FightingPhaseState.COUNTDOWN
		FightingPhaseState.COUNTDOWN: _fighting_phase_state = FightingPhaseState.NORMAL
		FightingPhaseState.NORMAL: _fighting_phase_state = FightingPhaseState.ACCELERATED
		FightingPhaseState.ACCELERATED: _fighting_phase_state = FightingPhaseState.CELEBRATING
		FightingPhaseState.CELEBRATING: _fighting_phase_state = FightingPhaseState.FINISHED
		FightingPhaseState.FINISHED: _fighting_phase_state = FightingPhaseState.UNDEF
		_: pass


func _on_fighting_phase_state_changed(new_fighting_phase_state: FightingPhaseState) -> void:
	var duration: float = GameManager.game_rules.duration_fighting_positioning
	match new_fighting_phase_state:
		FightingPhaseState.POSITIONING:
			duration = GameManager.game_rules.duration_fighting_positioning
			Verbose.debug("[State=POSITIONING] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		
		FightingPhaseState.COUNTDOWN:
			duration = GameManager.game_rules.duration_fighting_countdown
			Verbose.debug("[State=COUNTDOWN] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		
		FightingPhaseState.NORMAL:
			duration = GameManager.game_rules.duration_fighting_normal
			Verbose.debug("[State=FIGHTING_NORMAL] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		
		FightingPhaseState.ACCELERATED:
			duration = GameManager.game_rules.duration_fighting_accelerated
			Verbose.debug("[State=FIGHTING_ACCELERATED] (" + str(duration) + "s)", Verbose.Category.GLOBAL_MANAGER)
			Engine.time_scale = ACCELERATED_FIGHT_TIME_SCALE
		
		FightingPhaseState.CELEBRATING:
			duration = GameManager.game_rules.duration_fighting_celebrating
			Verbose.debug("[State=FIGHTING_CELEBRATING] (" + str(duration) + "s)", Verbose.Category.GLOBAL_MANAGER)
			Engine.time_scale = 1.0
			if multiplayer.is_server(): _wait_for_all_players_to_finish_playback()
			else: _notice_playback_is_over.rpc_id(1)
		
		FightingPhaseState.FINISHED:
			duration = GameManager.game_rules.duration_fighting_finished
			Verbose.debug("[State=FIGHTING_FINISHED] (" + str(duration) + "s)", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		
		_:
			return
	
	_timer.wait_time = duration
	_timer.start()


func _on_game_manager_game_state_changed(new_game_state: GameManager.GameState) -> void:
	match new_game_state:
		GameManager.GameState.ENDING_ROUND:
			pass # TODO handle the GameManager watchdog
		_: pass

# ============================== State changed callbacks ==============================


signal _all_players_playback_finished()
func _wait_for_all_players_to_finish_playback() -> void:
	if not multiplayer.is_server(): return
	Verbose.debug("Waiting for clients to finish their playback", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if GameManager.game_type != GameManager.GameType.SOLO and not _players_running_playback.is_empty():
		await _all_players_playback_finished
	_finish_all_fights.rpc()


@rpc("authority", "call_local")
func _finish_all_fights() -> void:
	all_fights_are_over.emit()
	Verbose.debug("Finishing GFM, returning to main game loop", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	_players_running_playback.clear()


@rpc("any_peer", "call_remote")
func _notice_playback_is_over() -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	Verbose.debug("Player(" + str(peer_id) + ") finished its playback", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	if _players_running_playback.has(PlayerManager.players[peer_id]):
		_players_running_playback.erase(PlayerManager.players[peer_id])
	else:
		Verbose.error("Player(" + str(peer_id) + ") notice playback is finished but is not listed", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
	
	if _players_running_playback.is_empty():
		_all_players_playback_finished.emit()

# ============================== FightingManager callbacks ==============================

func _fighting_manager_fighting_is_over(fighting_manager: FightingManager, _winner_teams_order: Array[int]) -> void:
	if not _current_active_fighting_managers.has(fighting_manager):
		Verbose.error("An unexpected FightingArea signal 'a fight is over' [" + str(fighting_manager.get_path()) + "]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	_current_active_fighting_managers.erase(fighting_manager)
	if _current_active_fighting_managers.is_empty():
		GameManager.update_game_state(Game.GameState.FIGHTING_CELEBRATING)


func _on_fighting_manager_fight_is_ready_to_be_started(fighting_manager: FightingManager) -> void:
	if _current_active_fighting_managers.has(fighting_manager):
		Verbose.error("A fight is starting more than once at the same time on the same FightingArea [" + str(fighting_manager.get_path()) + "]", Verbose.Category.GLOBAL_FIGHTING_MANAGER)
		return
	_current_active_fighting_managers.append(fighting_manager)



















 
