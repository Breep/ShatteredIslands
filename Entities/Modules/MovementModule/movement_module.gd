class_name MovementModule
extends Module

var _target_position: Vector3
var _is_moving: bool = false
var _is_stopped: bool = false

# Follow entity mode
var _target_entity: Entity = null
var _follow_entity: bool = false

# Rush mode
var _is_rushing: bool = false
var _rush_speed: float = 0.0

func start() -> void:
	Verbose.debug("start", Verbose.Category.MOVEMENT_MODULE)
	_is_stopped = false
	
	if _owner.status_module != null and not _owner.status_module.stunned_changed.is_connected(_on_owner_stunned_changed):
		_owner.status_module.stunned_changed.connect(_on_owner_stunned_changed)


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


## Called every physics tick by FightingManager (deterministic, fixed 1/60s step).
func process_tick() -> void:
	if _is_stopped:
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


func rush(speed: float, target_global_position: Vector3) -> void:
	Verbose.debug("rush", Verbose.Category.MOVEMENT_MODULE)
	_is_rushing = true
	_rush_speed = speed
	set_target_position(target_global_position)


func _stop_rushing() -> void:
	_is_rushing = false
	_rush_speed = 0.0


func _get_move_speed() -> float:
	return 4 # _owner.stats.move_speed
