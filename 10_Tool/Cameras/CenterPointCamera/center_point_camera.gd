class_name CenterPointCamera
extends Node3D

# ============================== Local node ==============================

@export var _camera: Camera3D
@export var _clicker_module: ClickerModule

# ============================== Configuration ==============================

@export var _rotation_sensitivity: float = 0.3
@export var _zoom_sensitivity: float = 1.0

@export var _zoom_min: float = 10.0
@export var _zoom_max: float = 40.0

var _is_active: bool = false

# ============================== Node base functions ==============================

func _unhandled_input(event: InputEvent) -> void:
	if not _is_active: return
	_handle_center_point_rotation(event)
	_handle_camera_zoom(event)

# ============================== Public functions ==============================

func set_active() -> void:
	if _is_active: return
	_is_active = true
	_camera.make_current()
	_clicker_module.set_active()


func set_inactive() -> void:
	if not _is_active: return
	_is_active = false
	_clicker_module.set_inactive()

# ============================== Private functions ==============================

var _rotating := false
func _handle_center_point_rotation(event: InputEvent) -> void:
	if event.is_action_pressed("camera_rotate"):
		_rotating = true
	elif event.is_action_released("camera_rotate"):
		_rotating = false
	
	if _rotating:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion and _rotating:
		var delta = event.relative
		rotate_y(deg_to_rad(-delta.x * _rotation_sensitivity))
		var x_rotation = delta.y * _rotation_sensitivity
		var new_rotation = rotation_degrees.x + x_rotation
		# Clamp the vertical rotation to avoid flipping
		new_rotation = clamp(new_rotation, -80, 80)
		rotation_degrees.x = new_rotation


func _handle_camera_zoom(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		_camera.position.x -= _zoom_sensitivity
	elif event.is_action_pressed("camera_zoom_out"):
		_camera.position.x += _zoom_sensitivity
	_camera.position.x = clampf(_camera.position.x, _zoom_min, _zoom_max)
