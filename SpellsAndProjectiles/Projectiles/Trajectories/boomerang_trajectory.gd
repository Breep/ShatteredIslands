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
	var target_pos := _target.global_position + Vector3.UP * vertical_offset
	_direction = (target_pos - _start_pos).normalized()


func update(delta: float) -> void:
	_life += delta
	
	var half_lifetime := lifetime * 0.5
	
	if _life < half_lifetime:
		# Phase 1: Fly forward
		_projectile.global_position += _direction * speed * delta
		_projectile.look_at(_projectile.global_position + _direction)
	else:
		# Phase 2: Return to source
		if not _is_returning:
			_is_returning = true
			# Note: We could clear hit history here if projectile tracks it
		
		if not _source or not is_instance_valid(_source):
			# Source disappeared, just continue forward or self-destruct
			return
		
		var return_dir := _projectile.global_position.direction_to(_source.global_position)
		_projectile.global_position += return_dir * speed * delta
		
		if return_dir.length_squared() > 0.001:
			_projectile.look_at(_projectile.global_position + return_dir)
		
		# Check if close enough to source to be "caught"
		if _projectile.global_position.distance_squared_to(_source.global_position) < 1.0:
			# Projectile will be destroyed by the Projectile class
			pass


func _on_retarget() -> void:
	# Boomerang doesn't retarget - it has a fixed outward direction
	# This might be called for bouncing, but boomerangs typically don't bounce
	pass
