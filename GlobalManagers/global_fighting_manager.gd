extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Handle the differents fighting phases (NORMAL/ACCELERATED/FINISHED) for every other FightingManager

# ============================== Signals ==============================

signal state_changed(state: FightingState)
signal all_fights_are_over()
signal countdown_started(time: float, text: String)

# ============================== Enums ==============================

enum FightingState {
	POSITIONING, # Positioning phase
	COUNTDOWN, # Beggining countdown
	FIGHTING, # Normal speed fight
	FIGHTING_ACCELERATED, # 10 seconds accelerated fight
	CELEBRATING, # Either only one team remains alive or times up
	FINISHED,
	UNDEF
}

# ============================== Fighting phase duration ==============================

const _fighting_phase_durations: Dictionary[FightingState, float] = {
	FightingState.POSITIONING: 10,
	FightingState.COUNTDOWN: 3,
	FightingState.FIGHTING: 30,
	FightingState.FIGHTING_ACCELERATED: 10 * ACCELERATED_FIGHT_TIME_SCALE,
	FightingState.CELEBRATING: 3, # Winners cheers
}

# ============================== Public variables ==============================

var timer: Timer

var SERVER_TIME_SCALE: float = 1.0

# ============================== Private variables ==============================

var _fighting_state: FightingState = FightingState.UNDEF
var fighting_state: FightingState:
	get:
		return _fighting_state
	set(value):
		if _fighting_state == value: return
		_fighting_state = value
		state_changed.emit(value)

var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]

var __prototyping: bool = false
const ACCELERATED_FIGHT_TIME_SCALE: float = 2.0

# ====== SERVER ONLY

var _players_running_playback: Array[Player]

# ============================== Node base functions ==============================

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.name = "GlobalFightingTimer"
	timer.timeout.connect(_on_timer_timeout)
	state_changed.connect(_on_state_changed)

# ============================== Public functions ==============================

func start(prototyping: bool = false) -> void:
	if not multiplayer.is_server(): return
	__prototyping = prototyping
	if __prototyping: SERVER_TIME_SCALE = 1
	fighting_state = FightingState.POSITIONING
	timer.wait_time = _fighting_phase_durations[FightingState.POSITIONING]
	_players_running_playback = PlayerManager.get_human_players().values().duplicate()
	timer.start()


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

# ============================== Private functions ==============================

# ===== RPC sync fighting state

@rpc("authority", "call_remote")
func _sync_state(server_fighting_state: FightingState) -> void:
	fighting_state = server_fighting_state

# ============================== Timer callbacks ==============================

# Fighting state machine
func _on_timer_timeout() -> void:
	match fighting_state:
		FightingState.POSITIONING: # End of POSITIONING State
			_sync_state.rpc(FightingState.COUNTDOWN) # Trigger COUNTDOWN STATE on client
			if __prototyping:
				fighting_state = FightingState.COUNTDOWN # Trigger COUNTDOWN STATE for prototyping map
				return
			else:
				fighting_state = FightingState.FIGHTING # Trigger FIGHT directly on server
				timer.wait_time = _fighting_phase_durations[FightingState.FIGHTING]
			timer.start()
		
		FightingState.COUNTDOWN: # End of COUNTDOWN State (Client only (or prototyping))
			fighting_state = FightingState.FIGHTING
		
		FightingState.FIGHTING: # End of FIGHTING State
			fighting_state = FightingState.FIGHTING_ACCELERATED
		
		FightingState.FIGHTING_ACCELERATED: # End of ACCELERATED FIGHT State
			fighting_state = FightingState.CELEBRATING
		
		FightingState.CELEBRATING: # End of CELEBRATING State
			fighting_state = FightingState.FINISHED


# ============================== State changed callbacks ==============================

func _on_state_changed(new_state) -> void:
	timer.stop()
	match new_state:
		FightingState.POSITIONING:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the positioning")
			_sync_state.rpc(FightingState.POSITIONING)
		
		FightingState.COUNTDOWN:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting countdown")
			countdown_started.emit(_fighting_phase_durations[FightingState.COUNTDOWN], "Fight")
			timer.wait_time = _fighting_phase_durations[FightingState.COUNTDOWN]
			timer.start()
		
		FightingState.FIGHTING:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the fight")
			if multiplayer.is_server(): Engine.time_scale = SERVER_TIME_SCALE
			timer.wait_time = _fighting_phase_durations[FightingState.FIGHTING]
			timer.start()
		
		FightingState.FIGHTING_ACCELERATED:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the accelerated fight")
			Engine.time_scale = ACCELERATED_FIGHT_TIME_SCALE
			timer.wait_time = _fighting_phase_durations[FightingState.FIGHTING_ACCELERATED]
			timer.start()
		
		FightingState.CELEBRATING:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the celebrating phase (dance)")
			Engine.time_scale = 1
			timer.wait_time = _fighting_phase_durations[FightingState.CELEBRATING]
			timer.start()
		
		FightingState.FINISHED:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: FINISHED")
			# START the watchdog timer on server
			if multiplayer.is_server(): _wait_for_all_players_to_finish_playback()
			else: _notice_playback_is_over.rpc_id(1)


signal _all_players_playback_finished()
func _wait_for_all_players_to_finish_playback() -> void:
	if not multiplayer.is_server(): return
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Waiting for clients to finish their playback")
	if not _players_running_playback.is_empty():
		await _all_players_playback_finished
	_finish_all_fights.rpc()


@rpc("authority", "call_local")
func _finish_all_fights() -> void:
	timer.stop()
	all_fights_are_over.emit()
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Finishing GFM, returning to main game loop")
	fighting_state = FightingState.UNDEF
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
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: A FIGHT IS OVER")
	if not _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: An unexpected FightingArea signal a fight is over [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.erase(fighting_manager)
	if _fighting_state != FightingState.CELEBRATING or _fighting_state != FightingState.FINISHED: return
	if _current_active_fighting_managers.is_empty():
		fighting_state = FightingState.CELEBRATING


func _on_fighting_manager_fight_is_ready_to_be_started(fighting_manager: FightingManager) -> void:
	print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: A FIGHT IS READY TO START")
	if _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: A fight is starting more than once at the same time on the same FightingArea [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.append(fighting_manager)



















 
