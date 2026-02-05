class_name MovementModule
extends Module

var _target_position: Vector3
var _is_moving: bool = false
var _is_stopped: bool = false

# Follow entity mode
var _target_entity: Entity = null
var _follow_entity: bool = false

func start() -> void:
	_is_stopped = false


func stop() -> void:
	_is_stopped = true


func set_target_position(target_position: Vector3) -> void:
	_target_position = target_position
	_is_moving = true


func move_to_entity(entity: Entity) -> void:
	if entity:
		set_target_position(entity.global_position)
	else:
		printerr("MovementModule.move_to_entity: entity is null")


func follow_entity(entity: Entity) -> void:
	Verbose.debug("Start following entity", Verbose.Category.ENTITY_MODULE)
	if entity:
		_target_entity = entity
		_follow_entity = true
		_is_moving = true
	else:
		printerr("MovementModule.follow_entity: entity is null")


func stop_following() -> void:
	_follow_entity = false
	_target_entity = null
	_is_moving = false
	# Reset velocity so animation can return to idle
	_owner.velocity = Vector3.ZERO


func _process(delta: float) -> void:
	if _is_stopped:
		return
	_move_toward_target(delta)


func _move_toward_target(delta: float):
	if not _is_moving:
		return
	
	# Update target position if following an entity
	if _follow_entity and _target_entity != null:
		if not is_instance_valid(_target_entity) or _target_entity.is_queued_for_deletion():
			stop_following()
			return
		_target_position = _target_entity.global_position
	
	if _target_position == null or _owner.global_position.distance_to(_target_position) < 0.1:
		if not _follow_entity:
			_is_moving = false
			# Reset velocity so animation can return to idle
			_owner.velocity = Vector3.ZERO
		return
	
	var direction: Vector3 = (_target_position - _owner.global_position).normalized()
	_owner.look_at_target_y_only(_target_position)
	_owner.velocity = direction * _get_move_speed() * delta
	_owner.move_and_slide()


func _get_move_speed() -> float:
	return 1000.0
