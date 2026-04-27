extends Node3D

@export var _center_point_camera: CenterPointCamera
@export var _free_fly_camera: FreeFlyCamera

func _ready() -> void:
	if _center_point_camera != null:
		_center_point_camera.set_active()
	
	if _free_fly_camera != null:
		_free_fly_camera.set_active()


func _process(delta):
	if Input.is_action_pressed("scene_switch_1"):
		Engine.time_scale = 0.1
	if Input.is_action_pressed("scene_switch_2"):
		Engine.time_scale = 1
