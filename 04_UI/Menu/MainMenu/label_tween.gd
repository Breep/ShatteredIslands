extends Label
class_name JuicyLabel

@export var hover_animate := true
@export var appear_on_ready := true
@export var text_reveal_on_ready := false

@export var scale_with_width := true
@export var reference_width := 300.0
@export var max_hover_scale := 1.15

@export var hover_scale_x_power := 0.12
@export var hover_scale_y_power := 0.08

@export var hover_duration_x := 0.18
@export var hover_duration_y := 0.30
@export var unhover_duration_x := 0.15
@export var unhover_duration_y := 0.22

@export var rotation_amount := 2.5
@export var rotation_duration := 0.10
@export var rotation_return_duration := 0.10
@export var rotation_return_delay := 0.10
@export var use_random_rotation_direction := true

@export var use_color_on_hover := true
@export var normal_color := Color.WHITE
@export var hover_color := Color(1.0, 0.85, 0.45, 1.0)
@export var color_duration := 0.12

@export var appear_duration := 0.25
@export var appear_from_scale := Vector2(0.85, 0.85)
@export var appear_from_alpha := 0.0

@export var reveal_speed := 0.025

var tween: Tween
var reveal_tween: Tween
var full_text := ""


func _ready() -> void:
	pivot_offset = size / 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP

	full_text = text

	mouse_entered.connect(hover)
	mouse_exited.connect(unhover)

	add_theme_color_override("font_color", normal_color)

	if appear_on_ready:
		appear.call_deferred()

	if text_reveal_on_ready:
		reveal_text.call_deferred()


func hover() -> void:
	if not hover_animate:
		return

	pivot_offset = size / 2.0

	var scale_ratio := clampf(reference_width / max(size.x, 1.0), 0.5, 1.0)

	var scale_target_x := 1.0 + hover_scale_x_power * scale_ratio
	var scale_target_y := 1.0 + hover_scale_y_power * scale_ratio

	if not scale_with_width:
		scale_target_x = max_hover_scale
		scale_target_y = max_hover_scale
		scale_ratio = 1.0

	var rotation_direction := 1.0
	if use_random_rotation_direction:
		rotation_direction = [-1.0, 1.0].pick_random()

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "scale:x", scale_target_x, hover_duration_x)
	tween.parallel().tween_property(self, "scale:y", scale_target_y, hover_duration_y)

	tween.parallel().tween_property(
		self,
		"rotation_degrees",
		rotation_amount * scale_ratio * rotation_direction,
		rotation_duration
	)

	tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.0,
		rotation_return_duration
	).set_delay(rotation_return_delay)

	if use_color_on_hover:
		tween.parallel().tween_method(
			_set_font_color,
			get_theme_color("font_color"),
			hover_color,
			color_duration
		)


func unhover() -> void:
	pivot_offset = size / 2.0

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "scale:x", 1.0, unhover_duration_x)
	tween.parallel().tween_property(self, "scale:y", 1.0, unhover_duration_y)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.15)

	if use_color_on_hover:
		tween.parallel().tween_method(
			_set_font_color,
			get_theme_color("font_color"),
			normal_color,
			color_duration
		)


func appear() -> void:
	if tween and tween.is_running():
		tween.kill()

	pivot_offset = size / 2.0
	scale = appear_from_scale
	modulate.a = appear_from_alpha

	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "scale", Vector2.ONE, appear_duration)
	tween.parallel().tween_property(self, "modulate:a", 1.0, appear_duration)


func reveal_text() -> void:
	if reveal_tween and reveal_tween.is_running():
		reveal_tween.kill()

	text = ""
	var letters := full_text.length()

	reveal_tween = create_tween()

	for i in range(letters):
		reveal_tween.tween_callback(func(index := i):
			text = full_text.substr(0, index + 1)
		)
		reveal_tween.tween_interval(reveal_speed)


func set_new_text(new_text: String, reveal := true) -> void:
	full_text = new_text
	text = new_text

	if reveal:
		reveal_text()


func _set_font_color(value: Color) -> void:
	add_theme_color_override("font_color", value)
