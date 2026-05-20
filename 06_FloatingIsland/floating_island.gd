class_name FloatingIsland
extends Node3D

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _center_point_camera: CenterPointCamera

# ============================== Node base functions ==============================

func _ready() -> void:
	if _center_point_camera == null:
		printerr("FloatingIsland: Need a CenterPointCamera [", get_path(), "]")

# ============================== Public functions ==============================

func set_active() -> void:
	show()
	pass


func set_inactive() -> void:
	hide()
	pass


func get_fighting_area() -> FightingArea:
	return null
