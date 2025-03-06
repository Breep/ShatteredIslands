extends Camera3D

@export var move_speed: float = 10.0  # Vitesse de déplacement de la caméra

@export var debug_mesh: DebugMesh

var _is_active: bool = false

func _ready() -> void:
	CameraManager.camera_changed.connect(_on_camera_manager_camera_changed)

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


func _input(event):
	if not _is_active: return
	if event is InputEventMouseMotion:
		_select_object(event.position)


var _old_selected_object: Node3D
func _select_object(screen_position):
	if not _is_active: return
	# Convert screen position to a ray in 3D
	var ray_origin = project_ray_origin(screen_position)
	var ray_dir = project_ray_normal(screen_position)
	
	# Define the ray end position (extend it far enough)
	var ray_end = ray_origin + ray_dir * 1000  # 1000 units ahead
	
	if debug_mesh != null:
		debug_mesh.draw_line(ray_origin, ray_end)
	
	# Perform the raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var selected_object: Node3D = result.collider
		if selected_object != _old_selected_object:
			if selected_object.has_user_signal("focused"):
				selected_object.emit_signal("focused")
			if _old_selected_object != null and _old_selected_object.has_user_signal("unfocused"):
				_old_selected_object.emit_signal("unfocused")
		_old_selected_object = result.collider
	elif _old_selected_object != null:
		if _old_selected_object.has_user_signal("unfocused"):
			_old_selected_object.emit_signal("unfocused")
		_old_selected_object = null


func _on_camera_manager_camera_changed(camera_type: CameraManager.CameraType) -> void:
	if camera_type != CameraManager.CameraType.BUYING_AREA:
		_is_active = false
		return
	
	print("Switch to buying area camera")
	_is_active = true
	make_current()



















 
