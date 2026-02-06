class_name StraightTrajectory
extends ProjectileTrajectory

## Simple straight-line trajectory that moves directly toward the target.
## Updates direction every frame to follow moving targets.

@export var vertical_offset: float = 1.0  # Height offset from target position


func update(delta: float) -> void:
	if not is_instance_valid(_projectile): return
	if not _target or not is_instance_valid(_target): return
	
	var target_pos: Vector3 = _target.global_position + Vector3.UP * vertical_offset
	var direction: Vector3 = (target_pos - _projectile.global_position).normalized()
	
	_projectile.global_position += direction * speed * delta
	_projectile.look_at(target_pos)
