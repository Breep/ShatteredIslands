class_name Turret
extends Node3D

@export var _projectile_spawn_point: SpawnPoint

var target: Entity

func _process(delta: float) -> void:
	if target != null:
		look_at(target.global_position + 1 * Vector3.UP)
