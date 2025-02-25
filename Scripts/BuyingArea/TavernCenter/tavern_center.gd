class_name TavernCenter
extends Node3D

var _battle_types = {
	Battle.BattleType.VS_1: 0,
	Battle.BattleType.VS_2: 0,
	Battle.BattleType.FFA_SOLO_3: 0,
}

func _ready() -> void:
	for child in get_children(true):
		child.hide()


func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	var battles_number = battles.size()
	
	for battle in battles:
		match battle.battle_type:
			Battle.BattleType.VS_1: _battle_types[Battle.BattleType.VS_1] += 1
			Battle.BattleType.VS_2: _battle_types[Battle.BattleType.VS_2] += 1
			Battle.BattleType.FFA_SOLO_3: _battle_types[Battle.BattleType.FFA_SOLO_3] += 1
	
	var tables_node: Node3D
	var player_left_node: Node3D
	match battles_number:
		1:
			if _battle_types[Battle.BattleType.VS_1] == 1:
				player_left_node = %"PlayersLeft_2"
				tables_node = %"1_1v1"
		2:
			if _battle_types[Battle.BattleType.VS_1] == 2:
				player_left_node = %"PlayersLeft_4"
				tables_node = %"2_1v1"
	
	_init_tables(tables_node, battles)
	tables_node.show()
	player_left_node.show()
	show()


func _init_tables(tables_node: Node3D, battles: Array[Battle]) -> void:
	var tables = tables_node.find_children("", "Table", true, false)
	if tables.is_empty():
		printerr("TavernCenter: There is no tables node corresponding to this battles combination")
		return
	
	var battles_duplicate: Array[Battle] = battles.duplicate()
	for table_raw in tables:
		var table: Table = table_raw
		table.show()
		for battle in battles_duplicate:
			if battle.battle_type == table.battle_type:
				table.connect_to_players(battle.players)
				battles_duplicate.erase(battle)
				pass

































 
