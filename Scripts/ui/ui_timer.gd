class_name UIContinousTimer
extends Control

# ============================== Private variables ==============================

var _timer : Timer

# ============================== Local nodes ==============================

@onready var _timer_label : Label = %TimerLabel
@onready var _timer_progress_bar : TextureProgressBar = %TimerProgressBar

# ============================== Public functions ==============================

func connect_timer(new_timer: Timer) -> void:
	_timer = new_timer

# ============================== Node base functions ==============================

func _ready() -> void:
	_update_visual()

func _process(_delta: float) -> void:
	await get_tree().create_timer(0.05).timeout
	if _timer and _timer.time_left > 0:
		show()
		_update_visual()
	else:
		hide()

# ============================== Private functions ==============================

func _update_visual() -> void:
	_timer_label.text = "[pulse freq=1.0 color=#FFD700 ease=-2.0]%d[/pulse]" % (_timer.time_left as int)
	_timer_progress_bar.value = (_timer.time_left / _timer.wait_time) * _timer_progress_bar.max_value
