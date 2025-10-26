class_name UITransitionScreen
extends Control

var _tween: Tween
@onready var _color_rect: ColorRect = %ColorRect

func _ready() -> void:
	_color_rect.color.a = 0.0  # Start fully transparent
	show()

func start_transition(duration: float) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()

	# Fade in then fade out
	_tween.tween_property(_color_rect, "color:a", 1.0, duration * 0.5)
	_tween.tween_property(_color_rect, "color:a", 0.0, duration * 0.5)
