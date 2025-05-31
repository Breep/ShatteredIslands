extends Camera3D

@export var move_speed: float = 10.0  # Vitesse de déplacement de la caméra

@export var debug_mesh: DebugMesh

var _is_active: bool = false

var _focused_object: Node3D
var _old_focused_object: Node3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_handle_camera_movement(delta)


func _handle_camera_movement(delta: float) -> void:
	if not _is_active: return
	var movement = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		movement.x -= 1
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	if Input.is_action_pressed("move_forward"):
		movement.y += 1
	if Input.is_action_pressed("move_backward"):
		movement.y -= 1

	if movement.length() > 0:
		movement = movement.normalized() * move_speed * delta
		translate(movement)


func _input(event: InputEvent):
	if not _is_active: return
	if event is InputEventMouseMotion:
		_select_object(event.position)
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if _focused_object != null and _focused_object.has_user_signal("interacted"):
			_focused_object.emit_signal("interacted")


func _select_object(screen_position):
	if not _is_active: return
	# Convert screen position to a ray in 3D
	var ray_origin = project_ray_origin(screen_position)
	var ray_dir = project_ray_normal(screen_position)
	
	# Define the ray end position (extend it far enough)
	var ray_end = ray_origin + ray_dir * 100  # 1000 units ahead
	
	if debug_mesh != null:
		debug_mesh.draw_line(ray_origin, ray_end)
	
	# Perform the raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		_focused_object = result.collider
		if _focused_object != _old_focused_object:
			if _focused_object.has_user_signal("focused"):
				_focused_object.emit_signal("focused")
			if _old_focused_object != null and _old_focused_object.has_user_signal("unfocused"):
				_old_focused_object.emit_signal("unfocused")
		_old_focused_object = result.collider
	elif _old_focused_object != null:
		if _old_focused_object.has_user_signal("unfocused"):
			_old_focused_object.emit_signal("unfocused")
		_old_focused_object = null


















 
