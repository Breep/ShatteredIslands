class_name Tavern
extends Node3D

@export var _tarven_center: TavernCenter



func _ready() -> void:
	_tarven_center.put_tables_according_to_battles(RoundManager.get_current_round_battles())
