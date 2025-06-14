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
	FIGHT, # Normal speed fight
	FIGHT_ACCELERATED, # 10 seconds accelerated fight
	FINISHED, # Either only one team remains alive or times up
	UNDEF
}

# ============================== Fighting phase duration ==============================

const _fighting_phase_durations: Dictionary[FightingState, int] = {
	FightingState.POSITIONING: 1,
	FightingState.COUNTDOWN: 3,
	FightingState.FIGHT: 10,
	FightingState.FIGHT_ACCELERATED: 1, 
	FightingState.FINISHED: 3, # Winners cheers
}

# ============================== Public variables ==============================

var timer: Timer

var SERVER_TIME_SCALE: float = 1

# ============================== Private variables ==============================

var _fighting_state: FightingState = FightingState.UNDEF
var fighting_state: FightingState:
	get:
		return _fighting_state
	set(value):
		if _fighting_state != value:
			_fighting_state = value
			state_changed.emit(value)

var _fighting_managers: Array[FightingManager]
var _current_active_fighting_managers: Array[FightingManager]

const __PROTOTYPING: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.name = "GlobalFightingTimer"
	timer.timeout.connect(_on_timer_timeout)
	state_changed.connect(_on_state_changed)
	if __PROTOTYPING: SERVER_TIME_SCALE = 1

# ============================== Public functions ==============================

func start() -> void:
	if not multiplayer.is_server(): return
	fighting_state = FightingState.POSITIONING
	timer.wait_time = _fighting_phase_durations[FightingState.POSITIONING]
	timer.start()


func register_fighting_manager(fighting_manager: FightingManager):
	if _fighting_managers.has(fighting_manager):
		printerr("FightingManager[", fighting_manager, "] already registered !")
		return
	
	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_started.connect(_on_fighting_manager_fight_is_started)
	fighting_manager.fight_is_over.connect(_fighting_manager_fighting_is_over)


func unregister_fighting_manager(fighting_manager: FightingManager):
	if not _fighting_managers.has(fighting_manager):
		printerr("FightingManager[", fighting_manager, "] is not registered !")
		return
	
	_fighting_managers.erase(fighting_manager)
	fighting_manager.fight_is_over.disconnect(_fighting_manager_fighting_is_over)

# ============================== Private functions ==============================

@rpc("authority", "call_local")
func _finish_all_fights() -> void:
	Engine.time_scale = 1
	timer.stop()
	all_fights_are_over.emit()

# ============================== RPC sync fighting state ==============================

@rpc("authority", "call_remote")
func _sync_state(server_fighting_state: FightingState) -> void:
	fighting_state = server_fighting_state

# ============================== Callbacks ==============================

# Fighting state machine
func _on_timer_timeout() -> void:
	match fighting_state:
		FightingState.POSITIONING:
			Engine.time_scale = SERVER_TIME_SCALE
			_sync_state.rpc(FightingState.COUNTDOWN) # Trigger COUNTDOWN STATE on client
			if __PROTOTYPING:
				fighting_state = FightingState.COUNTDOWN
				timer.wait_time = _fighting_phase_durations[FightingState.COUNTDOWN]
			else:
				fighting_state = FightingState.FIGHT
				timer.wait_time = _fighting_phase_durations[FightingState.FIGHT]
			timer.start()
		FightingState.COUNTDOWN:
			fighting_state = FightingState.FIGHT
			timer.wait_time = _fighting_phase_durations[FightingState.FIGHT]
			timer.start()
		FightingState.FIGHT:
			#Engine.time_scale = 3 # A VOIR PLUS TARD COMMENT SYNHRO ENTRE LES CLIENTS
			fighting_state = FightingState.FIGHT_ACCELERATED
			timer.wait_time = _fighting_phase_durations[FightingState.FIGHT_ACCELERATED]
			timer.start()
		FightingState.FIGHT_ACCELERATED:
			fighting_state = FightingState.FINISHED
			timer.wait_time = _fighting_phase_durations[FightingState.FINISHED]
			timer.start()
		FightingState.FINISHED:
			Engine.time_scale = 1
			_finish_all_fights.rpc()


func _on_state_changed(new_state) -> void:
	match new_state:
		FightingState.POSITIONING:
			_sync_state.rpc(FightingState.POSITIONING)
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the positioning")
		FightingState.COUNTDOWN:
			countdown_started.emit(_fighting_phase_durations[FightingState.COUNTDOWN], "Fight")
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting countdown")
		FightingState.FIGHT:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the fight")
		FightingState.FIGHT_ACCELERATED:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the accelerated fight")
		FightingState.FINISHED:
			print("[", multiplayer.get_unique_id(), "] GlobalFightingManager: Starting the finished phase (dance)")


func _fighting_manager_fighting_is_over(fighting_manager: FightingManager, _winner_teams_order: Array[int]) -> void:
	print("GlobalFightingManager: A FIGHT IS OVER")
	if not _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: An unexpected FightingArea signal a fight is over [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.erase(fighting_manager)
	if _current_active_fighting_managers.is_empty():
		fighting_state = FightingState.FINISHED
		print("ALL FIGHT ARE OVER")


func _on_fighting_manager_fight_is_started(fighting_manager: FightingManager) -> void:
	print("GlobalFightingManager: A FIGHT IS STARTING")
	if _current_active_fighting_managers.has(fighting_manager):
		printerr("GlobalFightingManager: A fight is starting more than once at the same time on the same FightingArea [", fighting_manager.get_path(), "]")
		return
	_current_active_fighting_managers.append(fighting_manager)



















 
