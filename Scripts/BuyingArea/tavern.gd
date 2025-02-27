class_name Tavern
extends Node3D

@export var _tarven_center: TavernCenter



func _ready() -> void:
	pass


func start_round(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)
