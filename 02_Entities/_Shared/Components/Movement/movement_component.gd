class_name MovementComponent
extends EntityComponent

enum OrbitFacing {
	TANGENT,
	CENTER,
	ANTI_CENTER,
	NONE
}

var _target_position: Vector3
var _is_moving: bool = false
var _is_stopped: bool = false

# Follow entity mode
var _target_entity: Entity = null
var _follow_entity: bool = false

# Rush mode
var _is_rushing: bool = false
var _rush_speed: float = 0.0

# Orbit mode
var _is_orbiting: bool = false
var _orbit_approaching: bool = false
var _orbit_center_entity: Entity = null
var _orbit_center_point: Vector3 = Vector3.ZERO
var _orbit_radius: float = 0.0
var _orbit_angular_speed: float = 0.0
var _orbit_current_angle: float = 0.0
var _orbit_facing: OrbitFacing = OrbitFacing.TANGENT


func start() -> void:
	Verbose.debug("start", Verbose.Category.MOVEMENT_MODULE)
	_is_stopped = false

	if _owner.alterations_module != null and not _owner.alterations_module.stunned_changed.is_connected(_on_owner_stunned_changed):
		_owner.alterations_module.stunned_changed.connect(_on_owner_stunned_changed)


func _on_owner_stunned_changed(is_active: bool, _duration: float, _infinite: bool) -> void:
	if is_active:
		stop()
	else:
		start()


func stop() -> void:
	Verbose.debug("stop", Verbose.Category.MOVEMENT_MODULE)
	_is_stopped = true


func set_target_position(target_position: Vector3) -> void:
	Verbose.debug("set_target_position", Verbose.Category.MOVEMENT_MODULE)
	_target_position = target_position
	_is_moving = true
	_owner.is_moving = true


func move_to_entity(entity: Entity) -> void:
	if entity:
		set_target_position(entity.global_position)
	else:
		Verbose.error("move_to_entity: entity is null", Verbose.Category.MOVEMENT_MODULE)


func follow_entity(entity: Entity) -> void:
	Verbose.debug("follow_entity", Verbose.Category.MOVEMENT_MODULE)
	if entity:
		_target_entity = entity
		_follow_entity = true
		_is_moving = true
		_owner.is_moving = true
	else:
		Verbose.error("follow_entity: entity is null", Verbose.Category.MOVEMENT_MODULE)


func stop_following() -> void:
	Verbose.debug("stop_following", Verbose.Category.MOVEMENT_MODULE)
	_follow_entity = false
	_target_entity = null
	_is_moving = false
	_owner.is_moving = false
	# Reset velocity so animation can return to idle
	_owner.velocity = Vector3.ZERO


func orbit_entity(entity: Entity, radius: float, angular_speed: float, facing: OrbitFacing = OrbitFacing.TANGENT) -> void:
	Verbose.debug("orbit_entity", Verbose.Category.MOVEMENT_MODULE)
	if entity == null:
		Verbose.error("orbit_entity: entity is null", Verbose.Category.MOVEMENT_MODULE)
		return
	_orbit_center_entity = entity
	_orbit_center_point = entity.global_position
	_start_orbit(radius, angular_speed, facing)


func orbit_point(center: Vector3, radius: float, angular_speed: float, facing: OrbitFacing = OrbitFacing.TANGENT) -> void:
	Verbose.debug("orbit_point", Verbose.Category.MOVEMENT_MODULE)
	_orbit_center_entity = null
	_orbit_center_point = center
	_start_orbit(radius, angular_speed, facing)


func stop_orbiting() -> void:
	Verbose.debug("stop_orbiting", Verbose.Category.MOVEMENT_MODULE)
	_is_orbiting = false
	_orbit_approaching = false
	_orbit_center_entity = null
	_orbit_radius = 0.0
	_orbit_angular_speed = 0.0
	_orbit_current_angle = 0.0
	_is_moving = false
	_owner.is_moving = false
	_owner.velocity = Vector3.ZERO


## Called every physics tick by FightingManager (deterministic, fixed 1/60s step).
func process_tick() -> void:
	if _is_stopped:
		return
	if _is_orbiting:
		_update_orbit()
		return
	_move_toward_target()


func _move_toward_target() -> void:
	if not _is_moving:
		return

	# Update target position if following an entity
	if _follow_entity and _target_entity != null:
		if not is_instance_valid(_target_entity) or _target_entity.is_queued_for_deletion():
			stop_following()
			return
		_target_position = _target_entity.global_position

	var speed: float = _rush_speed if _is_rushing else _get_move_speed()
	var step_distance: float = speed / 60.0

	if _target_position == null or _owner.global_position.distance_to(_target_position) < step_distance:
		if _is_rushing:
			_owner.global_position = _target_position
			_stop_rushing()
		if not _follow_entity:
			_is_moving = false
			_owner.is_moving = false
		return

	var direction: Vector3 = (_target_position - _owner.global_position).normalized()
	_owner.look_at_target_y_only(_target_position)
	_owner.global_position += direction * step_distance
	_owner.global_position = _owner.global_position.snapped(Vector3(0.01, 0.01, 0.01))


func _update_orbit() -> void:
	# Validate center entity if orbiting dynamically
	if _orbit_center_entity != null:
		if not is_instance_valid(_orbit_center_entity) or _orbit_center_entity.is_queued_for_deletion():
			stop_orbiting()
			return
		_orbit_center_point = _orbit_center_entity.global_position

	if _orbit_approaching:
		_update_orbit_approach()
	else:
		_update_orbit_circle()


func _update_orbit_approach() -> void:
	# Compute the closest point on the orbit circle
	var to_entity: Vector3 = _owner.global_position - _orbit_center_point
	to_entity.y = 0.0
	var approach_target: Vector3
	if to_entity.length_squared() < 0.01 * 0.01:
		# Entity is at center, approach angle 0
		approach_target = _orbit_center_point + Vector3(_orbit_radius, 0.0, 0.0)
	else:
		approach_target = _orbit_center_point + to_entity.normalized() * _orbit_radius

	var step_distance: float = _get_move_speed() / 60.0
	var distance: float = _owner.global_position.distance_to(approach_target)

	if distance < step_distance:
		# Arrived on the orbit circle
		_owner.global_position = approach_target.snapped(Vector3(0.01, 0.01, 0.01))
		_orbit_current_angle = _compute_initial_angle(_orbit_center_point)
		_orbit_approaching = false
		return

	var direction: Vector3 = (approach_target - _owner.global_position).normalized()
	_owner.look_at_target_y_only(approach_target)
	_owner.global_position += direction * step_distance
	_owner.global_position = _owner.global_position.snapped(Vector3(0.01, 0.01, 0.01))


func _update_orbit_circle() -> void:
	# Advance angle deterministically
	_orbit_current_angle += _orbit_angular_speed / 60.0

	# Wrap angle to [0, TAU) to prevent floating-point drift
	_orbit_current_angle = fmod(_orbit_current_angle, TAU)
	if _orbit_current_angle < 0.0:
		_orbit_current_angle += TAU

	# Compute new position on the circle (XZ plane)
	var new_position: Vector3 = Vector3(
		_orbit_center_point.x + cos(_orbit_current_angle) * _orbit_radius,
		0.0,
		_orbit_center_point.z + sin(_orbit_current_angle) * _orbit_radius
	)
	_owner.global_position = new_position.snapped(Vector3(0.01, 0.01, 0.01))

	# Face direction based on orbit facing mode
	if _orbit_facing == OrbitFacing.CENTER:
		_owner.look_at_target_y_only(_orbit_center_point)
	elif _orbit_facing == OrbitFacing.ANTI_CENTER:
		var dir = (_owner.global_position - _orbit_center_point)
		_owner.look_at_target_y_only(_owner.global_position + dir)
	elif _orbit_facing == OrbitFacing.NONE:
		pass
	else:
		# Tangent direction: perpendicular to radius, in direction of travel
		var tangent_sign: float = signf(_orbit_angular_speed)
		if tangent_sign == 0.0:
			tangent_sign = 1.0
		var look_target: Vector3 = _owner.global_position + Vector3(
			-sin(_orbit_current_angle) * tangent_sign,
			0.0,
			cos(_orbit_current_angle) * tangent_sign
		)
		_owner.look_at_target_y_only(look_target)


func rush(speed: float, target_global_position: Vector3) -> void:
	Verbose.debug("rush", Verbose.Category.MOVEMENT_MODULE)
	_is_rushing = true
	_rush_speed = speed
	set_target_position(target_global_position)


func _stop_rushing() -> void:
	_is_rushing = false
	_rush_speed = 0.0


func _start_orbit(radius: float, angular_speed: float, facing: OrbitFacing) -> void:
	_is_orbiting = true
	_orbit_radius = radius
	_orbit_angular_speed = angular_speed
	_orbit_facing = facing
	_is_moving = true
	_owner.is_moving = true
	# Cancel other movement modes
	_follow_entity = false
	_target_entity = null
	_is_rushing = false
	_rush_speed = 0.0
	# Determine if approach is needed
	var distance_to_center: float = _owner.global_position.distance_to(_orbit_center_point)
	var step_distance: float = _get_move_speed() / 60.0
	if absf(distance_to_center - radius) > step_distance:
		_orbit_approaching = true
	else:
		_orbit_approaching = false
		_orbit_current_angle = _compute_initial_angle(_orbit_center_point)


func _compute_initial_angle(center: Vector3) -> float:
	var dx: float = _owner.global_position.x - center.x
	var dz: float = _owner.global_position.z - center.z
	if absf(dx) < 0.01 and absf(dz) < 0.01:
		return 0.0
	return atan2(dz, dx)


func _get_move_speed() -> float:
	return 4 # _owner.stats.move_speed
