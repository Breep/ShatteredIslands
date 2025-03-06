extends Camera3D

@export var _move_speed: float = 25.0
@export var _look_sensitivity: float = 0.2

var _is_active: bool = false

func _ready():
	CameraManager.camera_changed.connect(_on_camera_manager_camera_changed)

func _input(event):
	if not _is_active: return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * _look_sensitivity))
		var new_pitch = rotation_degrees.x - event.relative.y * _look_sensitivity
		rotation_degrees.x = clamp(new_pitch, -89, 89)

	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_is_active = false

func _process(delta):
	if not _is_active: return
	var velocity = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		velocity += transform.basis.z
	if Input.is_action_pressed("move_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		velocity += transform.basis.x
	if Input.is_action_pressed("move_up"):
		velocity += transform.basis.y
	if Input.is_action_pressed("move_down"):
		velocity -= transform.basis.y

	velocity = velocity.normalized() * _move_speed
	global_transform.origin += velocity * delta


func _on_camera_manager_camera_changed(camera_type: CameraManager.CameraType) -> void:
	if camera_type != CameraManager.CameraType.FREE_FLY:
		_is_active = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	
	_is_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	make_current()



















 
