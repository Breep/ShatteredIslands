class_name TorchLight
extends OmniLight3D

@export var flicker_speed: float = 10.0
@export var flicker_strength: float = 0.3
@export var base_energy: float = 1.5

var _time := 0.0

func _process(delta: float) -> void:
	_time += delta * flicker_speed
	var noise = sin(_time * randf_range(0.8, 1.2)) * flicker_strength
	light_energy = base_energy + noise
