# Bouton du menu principal : étend UIButton (sons UI standards) et ajoute
# une animation hover (scale + rotation) pour un feel plus prononcé.
extends UIButton

@export var hover_animate := true
@export var scale_with_width := true

@export var reference_width := 300.0
@export var max_hover_scale := 1.2

@export var hover_scale_x_power := 0.20
@export var hover_scale_y_power := 0.20

@export var hover_duration_x := 0.20
@export var hover_duration_y := 0.35
@export var unhover_duration_x := 0.15
@export var unhover_duration_y := 0.22

@export var rotation_amount := 5.0
@export var rotation_duration := 0.10
@export var rotation_return_duration := 0.10
@export var rotation_return_delay := 0.10

@export var use_random_rotation_direction := true

var tween: Tween


func _ready() -> void:
	super._ready()
	pivot_offset = size / 2.0
	mouse_entered.connect(hover)
	mouse_exited.connect(unhover)


func hover() -> void:
	if not hover_animate:
		return

	pivot_offset = size / 2.0

	var scale_ratio := clampf(reference_width / size.x, 0.5, 1.0)

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
