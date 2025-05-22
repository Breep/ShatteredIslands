class_name CenterPointCamera
extends Node3D

@export var _camera: Camera3D

@export var _rotation_sensitivity: float = 0.3
@export var _zoom_sensitivity: float = 0.3

@export var _zoom_min: float = 10.0
@export var _zoom_max: float = 40.0

var rotating := false
var last_mouse_position := Vector2.ZERO

func _input(event: InputEvent) -> void:
	_handle_center_point_rotation(event)
	_handle_camera_zoom(event)


func _handle_center_point_rotation(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = event.pressed
			if rotating:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	elif event is InputEventMouseMotion and rotating:
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
