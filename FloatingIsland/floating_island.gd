class_name FloatingIsland
extends Node3D

# ============================== Local nodes ==============================

@export_group("Local Nodes")
@export var _center_point_camera: CenterPointCamera

# ============================== Private variables ==============================

var _is_active: bool = false

# ============================== Node base functions ==============================

func _ready() -> void:
	pass

# ============================== Public functions ==============================

# Spawn all characters on the FightingArea according to the battle
# Connect all characters to the FightingArea of the FloatingIsland
func start_fight(characters: Array[Character], battle_type: Battle.BattleType) -> void:
	pass


func set_active() -> void:
	pass


func set_inactive() -> void:
	pass
