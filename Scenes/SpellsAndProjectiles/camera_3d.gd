extends Node3D

@export var camera: Camera3D
@export var move_speed: float = 5.0
@export var look_sensitivity: float = 0.2

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.y
	if Input.is_action_pressed("move_down"):
		direction -= transform.basis.y

	direction = direction.normalized()
	global_translate(direction * move_speed * delta)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * look_sensitivity
		rotation_x -= event.relative.y * look_sensitivity
		rotation_x = clamp(rotation_x, -90, 90)
		
		rotation_degrees = Vector3(rotation_x, rotation_y, 0)

	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
