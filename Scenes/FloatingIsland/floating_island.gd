class_name FloatingIsland
extends Node3D

# ============================== Network export ==============================

@export var _player_owner_id : int = -1

# ============================== local node ==============================

@export var _fighting_area: FightingArea
@export var _map: Map
@export var _center_point_camera: CenterPointCamera

# ============================== Private variables ==============================

var _characters: Array[Character]

func _ready() -> void:
	_register_self_in_shared()


func start_fight(characters: Array[Character], battle_type: Battle.BattleType) -> void:
	_fighting_area.start_fight(characters, battle_type)


func _register_self_in_shared() -> void:
	pass
