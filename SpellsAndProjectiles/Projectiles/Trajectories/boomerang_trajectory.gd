class_name BoomerangTrajectory
extends ProjectileTrajectory

## Boomerang trajectory that flies straight for half its lifetime, then returns to source.
## Useful for abilities like shield throws that come back to the caster.

@export var lifetime: float = 4.0              # Total flight time before auto-destroy
@export var vertical_offset: float = 1.0       # Height offset

var _direction: Vector3
var _is_returning: bool = false
var _life: float = 0.0


func _on_init() -> void:
	# Calculate the initial direction (away from source toward target)
	var target_pos := _target.get_collision_center()
	_direction = (target_pos - _start_pos).normalized()


func update(logic_pos: Vector3, delta: float) -> Vector3:
	_life += delta
	
	var half_lifetime := lifetime * 0.5
	
	if _life < half_lifetime:
		logic_pos += _direction * speed * delta
		_projectile.look_at(logic_pos + _direction)
	else:
		if not _is_returning:
			_is_returning = true
		
		if not is_instance_valid(_source):
			# Source disappeared, just continue forward or self-destruct
			return logic_pos
		
		var return_dir := logic_pos.direction_to(_source.global_position)
		logic_pos += return_dir * speed * delta
		
		if return_dir.length_squared() > 0.001:
			_projectile.look_at(logic_pos + return_dir)
		
		# Check if close enough to source to be "caught"
		if logic_pos.distance_squared_to(_source.global_position) < 1.0:
			# Projectile will be destroyed by the Projectile class
			pass
	
	return logic_pos


func _on_retarget() -> void:
	# Boomerang doesn't retarget - it has a fixed outward direction
	# This might be called for bouncing, but boomerangs typically don't bounce
	pass
