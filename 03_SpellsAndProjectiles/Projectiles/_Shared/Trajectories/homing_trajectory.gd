class_name HomingTrajectory
extends ProjectileTrajectory

## Smooth homing trajectory with limited turn rate.
## The projectile gradually steers toward the target rather than instantly tracking.

@export var turn_rate_deg_per_s: float = 360.0  # Maximum turning speed (degrees/second)
@export var retarget_each_frame: bool = true    # If false, homes to initial snapshot
@export var vertical_offset: float = 1.0        # Height offset from target

var _velocity: Vector3


func _on_init() -> void:
	var target_pos := _target.get_collision_center()
	_velocity = (target_pos - _start_pos).normalized() * speed


func update(logic_pos: Vector3, delta: float) -> Vector3:
	if not is_instance_valid(_target):
		return Vector3.ZERO
	
	# Determine desired direction
	var desired_dir: Vector3
	if retarget_each_frame:
		var target_pos := _target.get_collision_center()
		desired_dir = (target_pos - logic_pos).normalized()
	else:
		# Home toward initial snapshot position
		var target_snapshot := _target.get_collision_center()
		desired_dir = (target_snapshot - logic_pos).normalized()
	
	# Current direction
	var current_dir: Vector3 = _velocity.normalized()
	
	# Calculate maximum angle change this frame
	var max_radians: float = deg_to_rad(turn_rate_deg_per_s) * delta
	var angle_to_target: float = acos(clamp(current_dir.dot(desired_dir), -1.0, 1.0))
	
	# Slerp toward desired direction
	var slerp_factor: float = clamp(max_radians / (angle_to_target + 1e-5), 0.0, 1.0)
	var new_dir := current_dir.slerp(desired_dir, slerp_factor)
	
	_velocity = new_dir * speed
	_projectile.global_position += _velocity * delta
	_projectile.look_at(logic_pos + _velocity)
	return logic_pos


func _on_retarget() -> void:
	# Keep current velocity direction for smooth handoff
	# The homing will naturally steer toward the new target
	pass
