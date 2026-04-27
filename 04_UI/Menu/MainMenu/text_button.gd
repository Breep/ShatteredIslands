class_name TextButton
extends Button

@onready var _default_font_size: float

@export var _font_increase: float = 1.2
@export var _animation_duration: float = 0.15

var _hover_tween: Tween

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Get the current effective font size from the theme
	_default_font_size = float(get_theme_font_size("font_size"))
	# Make sure we start with a clean override
	add_theme_font_size_override("font_size", int(_default_font_size))


func _on_mouse_entered() -> void:
	var target_size := _default_font_size * _font_increase
	_animate_font_size(target_size)


func _on_mouse_exited() -> void:
	_animate_font_size(_default_font_size)


func _animate_font_size(target_size: float) -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	var current_size := float(get_theme_font_size("font_size"))

	_hover_tween = create_tween()
	_hover_tween.tween_method(_set_font_size, current_size, target_size, _animation_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _set_font_size(size: float) -> void:
	add_theme_font_size_override("font_size", int(size))
