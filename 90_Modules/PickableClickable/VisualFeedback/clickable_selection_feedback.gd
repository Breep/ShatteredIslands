class_name ClickableSelectionFeedback
extends Node3D

var _color: Color = Color(1, 1, 1, 1)
@export var color: Color:
	get: return _color
	set(value):
		if value == _color or not is_node_ready(): return
		_color = value
		_decal.modulate = _color

@export var pulse_amount: float = 0.02     # % bigger on X/Z at peak
@export var pulse_duration: float = 0.8   # seconds for a grow/shrink cycle
@export var color_wobble: float = 0.3     # how much to lighten at peak
@export var color_duration: float = 1.0

@onready var _decal: Decal = %Decal

var _is_active: bool
var _size_base: Vector3
var _tween_size: Tween
var _tween_color: Tween


func _ready() -> void:
	_size_base = _decal.size
	_decal.modulate = color
	hide()


func set_active() -> void:
	if _is_active: return
	_is_active = true
	show()
	_start_pulse()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_stop_pulse()
	hide()


func _start_pulse() -> void:
	# safety: kill old tweens if still around
	if _tween_size and _tween_size.is_running():
		_tween_size.kill()
	if _tween_color and _tween_color.is_running():
		_tween_color.kill()

	# --- size pulse (X/Z only) ---
	var peak := Vector3(
		_size_base.x * (1.0 + pulse_amount),
		_size_base.y,  # keep Y the same
		_size_base.z * (1.0 + pulse_amount)
	)

	_tween_size = create_tween()
	_tween_size.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# grow to peak, then back to base
	_tween_size.tween_property(_decal, "size", Vector3(peak.x, _size_base.y, peak.z), pulse_duration * 0.5)
	_tween_size.tween_property(_decal, "size", _size_base,                            pulse_duration * 0.5)
	# loop forever while active
	_tween_size.set_loops(0)

	# --- color wobble around base color (lighten and back) ---
	var brighter := color.lightened(color_wobble)

	_tween_color = create_tween()
	_tween_color.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween_color.tween_property(_decal, "modulate", brighter,  color_duration * 0.5)
	_tween_color.tween_property(_decal, "modulate", color,    color_duration * 0.5)
	_tween_color.set_loops(0)


func _stop_pulse() -> void:
	if _tween_size:
		_tween_size.kill()
	if _tween_color:
		_tween_color.kill()
	# reset visuals
	_decal.size = _size_base
	_decal.modulate = color
