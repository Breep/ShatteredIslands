class_name StraightTrajectory
extends ProjectileTrajectory

## Simple straight-line trajectory that moves directly toward the target.
## Updates direction every frame to follow moving targets.

@export var vertical_offset: float = 1.0  # Height offset from target position


func update(logic_pos: Vector3, delta: float) -> Vector3:
	if not is_instance_valid(_projectile): return Vector3.ZERO
	if not _target or not is_instance_valid(_target): return Vector3.ZERO
	
	var target_pos: Vector3 = _target.get_collision_center()
	var direction: Vector3 = (target_pos - logic_pos).normalized()
	
	logic_pos += direction * speed * delta
	_projectile.look_at(target_pos)
	return logic_pos
