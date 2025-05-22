class_name MovementModule
extends Module

var _target_position: Vector3
var _is_moving: bool = false
var _is_stopped: bool = false

func init() -> void:
	Events.map_clicked.connect(_on_events_map_clicked)
	#if not source.player.is_bot:
		#Events.map_clicked.connect(_on_events_map_clicked)


func start() -> void:
	_is_stopped = false


func stop() -> void:
	_is_stopped = true


func set_target_position(target_position: Vector3) -> void:
	_target_position = target_position
	_is_moving = true


func _process(delta: float) -> void:
	if _is_stopped:
		return
	_move_toward_target(delta)


func _move_toward_target(delta: float):
	if not _is_moving:
		return
	
	if _target_position == null or source.global_position.distance_to(_target_position) < 0.1:
		_is_moving = false
		return
	
	var previous_position = source.global_position
	var direction: Vector3 = (_target_position - source.global_position).normalized()
	
	
	source.velocity = direction * _get_move_speed() * delta
	#print("DIRECTION ", direction)
	source.move_and_slide()
	var distance_moved = source.global_position.distance_to(previous_position)
	print("POS= ", source.global_position)


func _get_move_speed() -> float:
	var move_speed: float = source.stats.move_speed
	return move_speed


func _on_events_map_clicked(battle_id: int, clicked_position: Vector3) -> void:
	if not battle_id == source.battle_id:
		return
	
	clicked_position.y = 0
	print("SHOULD MOVE to ", clicked_position, "/", source.global_position)
	_target_position = clicked_position
	_is_moving = true
