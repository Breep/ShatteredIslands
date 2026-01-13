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

# Spawn all Heroes on the FightingArea according to the battle
# Connect all heroes to the FightingArea of the FloatingIsland
func start_fight(_heroes: Array[Hero], _battle_type: Battle.BattleType) -> void: # VIRTUAL
	pass


func set_active() -> void:
	show()
	pass


func set_inactive() -> void:
	hide()
	pass


func get_fighting_area() -> FightingArea:
	return null
