class_name CenterPointCamera
extends Node3D

# ============================== Local node ==============================

@export var _camera: Camera3D

# ============================== Configuration ==============================

@export var _rotation_sensitivity: float = 0.3
@export var _zoom_sensitivity: float = 0.5

@export var _zoom_min: float = 10.0
@export var _zoom_start: float = 20.0
@export var _zoom_max: float = 40.0

var _is_active: bool = false

# ============================== Node base functions ==============================

func _input(event: InputEvent) -> void:
	if not _is_active: return
	_handle_center_point_rotation(event)
	_handle_camera_zoom(event)


func _ready() -> void:
	_camera.position.x = _zoom_start

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	_camera.make_current()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	pass

# ============================== Private functions ==============================

var _rotating := false
func _handle_center_point_rotation(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_rotating = event.pressed
			if _rotating:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	elif event is InputEventMouseMotion and _rotating:
		var delta = event.relative
		rotate_y(deg_to_rad(-delta.x * _rotation_sensitivity))
		var x_rotation = -delta.y * _rotation_sensitivity
		var new_rotation = rotation_degrees.x + x_rotation
		# Clamp the vertical rotation to avoid flipping
		new_rotation = clamp(new_rotation, -80, 80)
		rotation_degrees.x = new_rotation


func _handle_camera_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera.position.x -= _zoom_sensitivity
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.position.x += _zoom_sensitivity
		_camera.position.x = clampf(_camera.position.x, _zoom_min, _zoom_max)
