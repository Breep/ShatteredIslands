class_name UIGameStateViewer
extends Control

const MAIN_GAME_STATE_TEXT: Dictionary [GameManager.GameState, String] = {
	GameManager.GameState.STARTING: "Starting game",
	GameManager.GameState.INIT_ROUND: "Initiating new round",
	GameManager.GameState.BUYING: "BUYING PHASE",
	GameManager.GameState.FIGHTING: "FIGHTING PHASE",
	GameManager.GameState.ENDING_ROUND: "Ending round",
	#Game.GameState.FIGHTING_POSITIONING: "FIGHTING PHASE - Positionoing",
	#Game.GameState.FIGHTING_COUNTDOWN: "FIGHTING PHASE - Countdown",
	#Game.GameState.FIGHTING_NORMAL: "FIGHTING PHASE - Normal",
	#Game.GameState.FIGHTING_ACCELERATED: "FIGHTING PHASE - Accelerated",
	#Game.GameState.FIGHTING_CELEBRATING: "FIGHTING PHASE - Celebrating",
	#Game.GameState.FIGHTING_FINISHED: "FIGHTING PHASE - Finished",
	GameManager.GameState.FINISHED: "FINISHED",
	GameManager.GameState.UNDEF: "UNDEF",
}

@onready var _game_state_label: RichTextLabel = %GameStateLabel
@onready var _timer_progress_bar: TextureProgressBar = %TimeLeftBar
@onready var _round_label: RichTextLabel = %RoundLabel
@onready var _timer_label: RichTextLabel = %TimeLeftLabel

const TIMER_BAR_MIN: float = 18
const TIMER_BAR_MAX: float = 82

var _timer: Timer

func _process(_delta: float) -> void:
	if _timer == null: return
	_timer_progress_bar.max_value = 100
	_timer_progress_bar.value = remap(_timer.time_left / _timer.wait_time, 0, 1, TIMER_BAR_MIN, TIMER_BAR_MAX) 
	_timer_label.text = str(_timer.time_left).pad_decimals(0)


func connect_timer(timer: Timer) -> void:
	_timer = timer


func update_game_state(game_state: GameManager.GameState) -> void:
	_game_state_label.text = MAIN_GAME_STATE_TEXT[game_state]


func update_round_value(round_number: int) -> void:
	_round_label.text = str(round_number)






 
