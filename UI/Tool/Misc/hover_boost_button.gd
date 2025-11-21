class_name HoverBoostButton
extends Button

#region === Configuration
@export_group("Configuration") 
@export var font_scale := 1.2
@export var click_scale := 1.3
@export var child_scale := 1.1
@export var child_click_scale := 1.2
@export var duration := 0.15
@export var click_duration := 0.10

@export var hover_modulate := Color(1, 1, 1, 1)
@export var click_modulate := Color(0.8, 0.8, 0.8, 1)
@export var normal_modulate := Color(1, 1, 1, 1)
#endregion

#region ===== Private variables
var _default_font_size: float
var _font_tween: Tween
var _children_tween: Tween
var _click_tween: Tween
var _modulate_tween: Tween

var _children: Array = []

var _is_hovered := false
var _is_click_bumping := false
#endregion

func _ready() -> void:
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)
	pressed.connect(_on_pressed)

	_default_font_size = float(get_theme_font_size("font_size"))
	add_theme_font_size_override("font_size", int(_default_font_size))

	_collect_children()

	for c in _children:
		if c is Control:
			c.pivot_offset = c.size * 0.5

	self.modulate = normal_modulate


func _collect_children() -> void:
	_children.clear()
	for child in get_children():
		if child is Control:
			_children.append(child)


# ------------------------------
# HOVER ENTER
# ------------------------------
func _on_enter() -> void:
	_is_hovered = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if _is_click_bumping:
		return

	_animate_font(_default_font_size * font_scale)
	_animate_children_scale(Vector2(child_scale, child_scale))
	_animate_modulate(hover_modulate)


# ------------------------------
# HOVER EXIT
# ------------------------------
func _on_exit() -> void:
	_is_hovered = false
	mouse_default_cursor_shape = Control.CURSOR_ARROW

	if _is_click_bumping:
		return

	_animate_font(_default_font_size)
	_animate_children_scale(Vector2.ONE)
	_animate_modulate(normal_modulate)


# ------------------------------
# CLICK BUMP
# ------------------------------
func _on_pressed() -> void:
	_is_click_bumping = true

	# Kill running tweens
	if _font_tween and _font_tween.is_valid(): _font_tween.kill()
	if _children_tween and _children_tween.is_valid(): _children_tween.kill()
	if _click_tween and _click_tween.is_valid(): _click_tween.kill()
	if _modulate_tween and _modulate_tween.is_valid(): _modulate_tween.kill()

	var start_font := float(get_theme_font_size("font_size"))

	_click_tween = create_tween()

	# Font bump
	_click_tween.tween_method(
		_set_font_size,
		start_font,
		_default_font_size * click_scale,
		click_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Children bump
	for c in _children:
		_click_tween.parallel().tween_property(
			c, "scale",
			Vector2(child_click_scale, child_click_scale),
			click_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Modulate bump
	_click_tween.parallel().tween_property(
		self, "modulate",
		click_modulate,
		click_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_click_tween.finished.connect(_on_click_bump_finished)


func _on_click_bump_finished() -> void:
	_is_click_bumping = false

	if _is_hovered:
		_animate_font(_default_font_size * font_scale)
		_animate_children_scale(Vector2(child_scale, child_scale))
		_animate_modulate(hover_modulate)
	else:
		_animate_font(_default_font_size)
		_animate_children_scale(Vector2.ONE)
		_animate_modulate(normal_modulate)


# ------------------------------
# ANIMATION HELPERS
# ------------------------------
func _animate_font(target_size: float, custom_duration := duration) -> void:
	if _font_tween and _font_tween.is_valid():
		_font_tween.kill()

	var start := float(get_theme_font_size("font_size"))

	_font_tween = create_tween()
	_font_tween.tween_method(_set_font_size, start, target_size, custom_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func _set_font_size(font_size: float) -> void:
	add_theme_font_size_override("font_size", int(font_size))


func _animate_children_scale(target: Vector2, custom_duration := duration) -> void:
	if _children_tween and _children_tween.is_valid():
		_children_tween.kill()

	_children_tween = create_tween()
	for c in _children:
		_children_tween.tween_property(c, "scale", target, custom_duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)


func _animate_modulate(target: Color, custom_duration := duration) -> void:
	if _modulate_tween and _modulate_tween.is_valid():
		_modulate_tween.kill()

	_modulate_tween = create_tween()
	_modulate_tween.tween_property(self, "modulate", target, custom_duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
