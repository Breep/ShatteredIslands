extends Node3D

@export var _center_point_camera: CenterPointCamera
@export var _clicker_module: ClickerModule

func _ready() -> void:
	if _center_point_camera != null:
		_center_point_camera.set_active()
	
	if _clicker_module != null:
		_clicker_module.set_active()
