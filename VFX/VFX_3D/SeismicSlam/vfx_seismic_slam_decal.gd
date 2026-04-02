extends Node3D

@onready var decal: Decal = $Decal

@export var decal_size: float = 12.0
@export var fade_in_duration: float = 0.15
@export var hold_duration: float = 1.5
@export var fade_out_duration: float = 1.5

func _ready() -> void:
	decal.size = Vector3(decal_size, 1.0, decal_size)
	decal.albedo_mix = 0.0
	decal.emission_energy = 0.0

	var tween := create_tween()
	# Fade in
	tween.tween_property(decal, "albedo_mix", 1.0, fade_in_duration)
	tween.parallel().tween_property(decal, "emission_energy", 8.0, fade_in_duration)
	# Hold
	tween.tween_interval(hold_duration)
	# Fade out
	tween.tween_property(decal, "albedo_mix", 0.0, fade_out_duration)
	tween.parallel().tween_property(decal, "emission_energy", 0.0, fade_out_duration)
	tween.tween_callback(queue_free)
