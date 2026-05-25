extends Control
class_name AutoTweenUI

@export var auto_start := true

@export_group("Float Movement")
@export var enable_float := true
@export var float_distance := 8.0
@export var float_duration := 2.0

@export_group("Rotation")
@export var enable_rotation := true
@export var rotation_amount := 2.0
@export var rotation_duration := 2.5

@export_group("Scale Pulse")
@export var enable_scale := false
@export var scale_amount := 0.03
@export var scale_duration := 1.8

@export_group("Random Offset")
@export var randomize_values := true
@export var random_strength := 0.25

var tween: Tween

var base_position := Vector2.ZERO
var base_rotation := 0.0
var base_scale := Vector2.ONE


func _ready() -> void:
	base_position = position
	base_rotation = rotation_degrees
	base_scale = scale

	pivot_offset = size / 2.0

	if auto_start:
		start_idle_animation()


func start_idle_animation() -> void:
	if tween and tween.is_running():
		tween.kill()

	var final_float_distance := float_distance
	var final_rotation_amount := rotation_amount
	var final_scale_amount := scale_amount

	if randomize_values:
		final_float_distance *= randf_range(
			1.0 - random_strength,
			1.0 + random_strength
		)

		final_rotation_amount *= randf_range(
			1.0 - random_strength,
			1.0 + random_strength
		)

		final_scale_amount *= randf_range(
			1.0 - random_strength,
			1.0 + random_strength
		)

	tween = create_tween()
	tween.set_loops()

	# FLOAT
	if enable_float:
		tween.parallel().tween_property(
			self,
			"position:y",
			base_position.y - final_float_distance,
			float_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.parallel().tween_property(
			self,
			"position:y",
			base_position.y,
			float_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# ROTATION
	if enable_rotation:
		tween.parallel().tween_property(
			self,
			"rotation_degrees",
			base_rotation + final_rotation_amount,
			rotation_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.parallel().tween_property(
			self,
			"rotation_degrees",
			base_rotation - final_rotation_amount,
			rotation_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.parallel().tween_property(
			self,
			"rotation_degrees",
			base_rotation,
			rotation_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# SCALE
	if enable_scale:
		tween.parallel().tween_property(
			self,
			"scale",
			base_scale * (1.0 + final_scale_amount),
			scale_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.parallel().tween_property(
			self,
			"scale",
			base_scale,
			scale_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func stop_idle_animation() -> void:
	if tween and tween.is_running():
		tween.kill()
