class_name FightingManager
extends Node

# ============================== Signals ==============================

signal state_changed(state: FightingState)

# ============================== Enums ==============================

enum FightingState {
	WAITING_FOR_PLAYERS, # Waiting for all player to load the scene
	STARTING, # Begginning countdown
	FIGHT, # 30 seconds of fight
	FIGHT_ACCELERATED, # 10 seconds accelerated fight
	ENDING, # Either only one team remains alive or times up
	FINISHED, # Go back to buying scene
}

# ============================== Fighting phase duration ==============================

@export var starting_count_down_duration: int # in seconds
@export var fight_duration: int # in seconds
@export var fight_accelerated_duration: int # in seconds
@export var ending_duration: int # in seconds

# ============================== Private variables ==============================

var _fighting_state: FightingState = FightingState.WAITING_FOR_PLAYERS

# ============================== Local nodes ==============================

@onready var _timer: Timer = %Timer

func start() -> void:
	_fighting_state = FightingState.STARTING
	state_changed.emit(_fighting_state)
	print("FightingManager: Starting the countdown")
	_timer.wait_time = starting_count_down_duration
	_timer.start()


func _on_timer_timeout() -> void:
	match _fighting_state:
		FightingState.WAITING_FOR_PLAYERS:
			printerr("FightingManager: Should not be waiting for players here")
		FightingState.STARTING:
			print("FightingManager: Starting the fight")
			_fighting_state = FightingState.FIGHT
			_timer.wait_time = fight_duration
			_timer.start()
			state_changed.emit(_fighting_state)
		FightingState.FIGHT:
			print("FightingManager: Starting the accelerated fight")
			_fighting_state = FightingState.FIGHT_ACCELERATED
			_timer.wait_time = fight_accelerated_duration
			_timer.start()
			state_changed.emit(_fighting_state)
		FightingState.FIGHT_ACCELERATED:
			print("FightingManager: Ending fight")
			_fighting_state = FightingState.ENDING
			_timer.wait_time = ending_duration
			_timer.start()
			state_changed.emit(_fighting_state)
		FightingState.ENDING:
			print("FightingManager: Going back to buying scene")
			_timer.wait_time = FightingState.FINISHED
			state_changed.emit(_fighting_state)
		FightingState.ENDING:
			printerr("FightingManager: Should not be in finished state")
