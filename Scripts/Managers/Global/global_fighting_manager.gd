extends Node

# ============================== Description ==============================
#
# -- GlobalFightingManager --
# Handle the differents fighting phases (NORMAL/ACCELERATED/FINISHED) for every other FightingManager

# ============================== Signals ==============================

signal state_changed(state: FightingState)
signal all_fights_are_over()

# ============================== Enums ==============================

enum FightingState {
	STARTING, # Begginning countdown
	FIGHT, # 30 seconds of fight
	FIGHT_ACCELERATED, # 10 seconds accelerated fight
	FINISHED, # Either only one team remains alive or times up
	UNDEF
}

# ============================== Fighting phase duration ==============================

const STARTING_DURATION: int = 5 # in seconds
const FIGHT_DURATION: int = 30 # in seconds
const FIGHT_ACCELERATED_DURATION: int = 10 # in seconds

# ============================== Public variables ==============================

var timer: Timer

# ============================== Private variables ==============================

var _fighting_state: FightingState = FightingState.UNDEF
var fighting_state: FightingState:
	get:
		return _fighting_state
	set(value):
		_fighting_state = value
		state_changed.emit(value)

var _fighting_managers: Array[FightingManager]
var _fights_over: int = 0

# ============================== Node base functions ==============================

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.name = "GlobalFightingTimer"
	timer.timeout.connect(_on_timer_timeout)
	state_changed.connect(_on_state_changed)

# ============================== Public functions ==============================

func start() -> void:
	if not multiplayer.is_server():
		return
	
	_fights_over = 0
	fighting_state = FightingState.STARTING
	timer.wait_time = STARTING_DURATION
	timer.start()


func register_fighting_manager(fighting_manager: FightingManager):
	if _fighting_managers.has(fighting_manager):
		printerr("FightingManager[", fighting_manager, "] already registered !")
		return
	
	_fighting_managers.append(fighting_manager)
	fighting_manager.fight_is_over.connect(_fighting_manager_fighting_is_over, CONNECT_ONE_SHOT)

# ============================== Callbacks ==============================

func _on_timer_timeout() -> void:
	match fighting_state:
		FightingState.STARTING:
			print("GlobalFightingManager: Starting the fight")
			fighting_state = FightingState.FIGHT
			timer.wait_time = FIGHT_DURATION
			timer.start()
		FightingState.FIGHT:
			print("GlobalFightingManager: Starting the accelerated fight (TODO)")
			#Engine.time_scale = 3 # A VOIR PLUS TARD COMMENT SYNHRO ENTRE LES CLIENTS
			fighting_state = FightingState.FIGHT_ACCELERATED
			timer.wait_time = FIGHT_ACCELERATED_DURATION
			timer.start()
		FightingState.FIGHT_ACCELERATED:
			print("GlobalFightingManager: Ending fight (CHECK FOR WINNER)")
			fighting_state = FightingState.FINISHED


func _on_state_changed(new_state) -> void:
	if new_state == FightingState.FINISHED:
		Engine.time_scale = 1
		timer.stop()
		all_fights_are_over.emit()


func _fighting_manager_fighting_is_over(_winning_team) -> void:
	print("GlobalFightingManager: A FIGHT IS OVER")
	_fights_over += 1
	if _fighting_managers.size() == _fights_over:
		fighting_state = FightingState.FINISHED
		print("ALL FIGHT ARE OVER")





















 
