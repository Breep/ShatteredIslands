class_name UIContinousTimer
extends Control

# ============================== Exports variables ==============================

@export var _timer: Timer

# ============================== Local nodes ==============================

#@onready var _timer_label : Label = %TimerLabel
@onready var _timer_progress_bar : TextureProgressBar = %TimerProgressBar

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_visual()


func _process(_delta: float) -> void:
	await get_tree().create_timer(0.05).timeout
	_update_visual()

# ============================== Public functions ==============================

func connect_timer(new_timer: Timer) -> void:
	_timer = new_timer

# ============================== Private functions ==============================

func _update_visual() -> void:
	if _timer and _timer.time_left > 0 and not _timer.is_stopped():
		show()
		#_timer_label.text = str(_timer.time_left as int)
		_timer_progress_bar.value = (_timer.time_left / _timer.wait_time) * _timer_progress_bar.max_value
	else:
		hide()
