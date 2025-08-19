class_name Tavern
extends Node3D

@export_group("External Nodes")
@export var _tarven_center: TavernCenter

func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)
