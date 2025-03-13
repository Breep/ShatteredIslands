class_name Tavern
extends Node3D

@export var _tarven_center: TavernCenter



func _ready() -> void:
	pass


func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	_tarven_center.put_tables_according_to_battles(battles)


func init_hero_selection(heroes: Array[Hero]) -> void:
	_tarven_center.init_hero_selection(heroes)
