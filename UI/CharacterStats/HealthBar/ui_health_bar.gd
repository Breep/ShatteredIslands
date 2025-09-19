class_name UIHealthBar
extends Control

# ============================== Configuration ==============================

@export var _health_per_segment: int = 100
@export var _hit_marker_wait_time: float = 0.2
@export var _watchdog_wait_time: float = 1.0

# ============================== Local Nodes ==============================

@onready var _segment_controls_container: HBoxContainer = %SegmentHBox
@onready var _current_health_label: Label = %CurrentHealthLabel
@onready var _health_progress_bar: ProgressBar = %HealthProgressBar
@onready var _hit_marker_progress_bar: ProgressBar = %HitMarkerProgressBar
@onready var _hit_marker_timer: Timer = %HitMarkerTimer
@onready var _watchdog_timer: Timer = %WatchdogTimer

# ============================== Constants ==============================

const UI_SEGMENT_CONTROL_SCENE: PackedScene = preload("res://UI/CharacterStats/HealthBar/ui_segment_control.tscn")

# ============================== Node base functions ==============================

func _ready() -> void:
	_hit_marker_timer.wait_time = _hit_marker_wait_time
	_watchdog_timer.wait_time = _watchdog_wait_time

# ============================== Public functions ==============================

func reset(current_health: int, max_health: int) -> void:
	_current_health_label.text = str(current_health)
	_health_progress_bar.value = current_health
	_hit_marker_progress_bar.value = _health_progress_bar.value
	_health_progress_bar.max_value = max_health
	_hit_marker_progress_bar.max_value = max_health

func update_current_health(current_health: int) -> void:
	_current_health_label.text = str(current_health)
	_health_progress_bar.value = current_health
	_hit_marker_timer.start()


func hide_label() -> void:
	_current_health_label.hide()


func show_label() -> void:
	_current_health_label.show()


func update_max_health(max_health: int) -> void:
	for segment_control in _segment_controls_container.get_children(): # 950 / 10 = 9 | 50
		segment_control.queue_free()
	var segment_control_number: int = max_health / _health_per_segment
	var remaining_health_segment: int = max_health - segment_control_number * _health_per_segment
	var last_segment_strech_ratio: float = (remaining_health_segment as float) / (_health_per_segment as float)
	if remaining_health_segment != 0: segment_control_number += 1
	for i in segment_control_number:
		var ui_segment_control: UISegmentControl = UI_SEGMENT_CONTROL_SCENE.instantiate()
		ui_segment_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if i == 0: ui_segment_control.hide_segment()
		if i == segment_control_number - 1 and remaining_health_segment != 0: 
			ui_segment_control.size_flags_stretch_ratio = last_segment_strech_ratio
		_segment_controls_container.add_child(ui_segment_control)
	
	_health_progress_bar.max_value = max_health
	_hit_marker_progress_bar.max_value = max_health

# ============================== Callbacks ==============================

func _on_hit_marker_timer_timeout() -> void:
	_hit_marker_progress_bar.value = _health_progress_bar.value


func _on_watchdog_timer_timeout() -> void:
	_hit_marker_progress_bar.value = _health_progress_bar.value
