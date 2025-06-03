class_name TableLayout
extends Node3D

@export var _tables: Array[Table]

func set_active(battles: Array[Battle]) -> void:
	show()
	for table in _tables:
		table.show()
	
	var battles_duplicate: Array[Battle] = battles.duplicate()
	for table in _tables:
		for battle in battles_duplicate:
			if battle.battle_type == table.battle_type:
				table.connect_to_players(battle.players)
				battles_duplicate.erase(battle)
				break


func set_inactive() -> void:
	hide()
	for table in _tables:
		table.hide()
