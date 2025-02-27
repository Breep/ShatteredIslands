extends Camera3D

@export var move_speed: float = 25.0
@export var look_sensitivity: float = 0.2

var velocity := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * look_sensitivity))
		var new_pitch = rotation_degrees.x - event.relative.y * look_sensitivity
		rotation_degrees.x = clamp(new_pitch, -89, 89)

	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	velocity = Vector3.ZERO

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

	velocity = velocity.normalized() * move_speed
	global_transform.origin += velocity * delta
