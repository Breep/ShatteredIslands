class_name UIGameStateViewer
extends Control

const MAIN_GAME_STATE_TEXT: Dictionary [Game.GameState, String] = {
	Game.GameState.STARTING: "Starting game",
	Game.GameState.INITIATING_NEW_ROUND: "Initiating new round",
	Game.GameState.BUYING: "BUYING PHASE",
	Game.GameState.FIGHTING_POSITIONING: "FIGHTING PHASE - Positionoing",
	Game.GameState.FIGHTING_COUNTDOWN: "FIGHTING PHASE - Countdown",
	Game.GameState.FIGHTING_NORMAL: "FIGHTING PHASE - Normal",
	Game.GameState.FIGHTING_ACCELERATED: "FIGHTING PHASE - Accelerated",
	Game.GameState.FIGHTING_CELEBRATING: "FIGHTING PHASE - Celebrating",
	Game.GameState.FIGHTING_FINISHED: "FIGHTING PHASE - Finished",
	Game.GameState.UNDEF: "UNDEF",
}

@export var _timer_progress_bar: FlexibleProgressBar
@export var _game_state_label: Label

var _timer: Timer

func _process(_delta: float) -> void:
	if _timer == null: return
	_timer_progress_bar.set_max_value(_timer.wait_time)
	_timer_progress_bar.set_bar_value(_timer.time_left)


func connect_timer(timer: Timer) -> void:
	_timer = timer
	_timer_progress_bar.set_max_value(_timer.wait_time)


func update_content(game_state: Game.GameState) -> void:
	_game_state_label.text = MAIN_GAME_STATE_TEXT[game_state]
