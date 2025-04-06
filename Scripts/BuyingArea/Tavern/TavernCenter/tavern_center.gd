class_name TavernCenter
extends Node3D

# ============================== Private variables ==============================


# ============================== Local nodes ==============================

@onready var _tables_layout_ref: Dictionary = {
	
}

# ============================== Node base functions ==============================

func _ready() -> void:
	Utils.recursive_hide(self)

# ============================== Public functions ==============================

func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	Utils.recursive_hide(self)
	
	var battle_types_number = {
		Battle.BattleType.VS_1: 0,
		Battle.BattleType.VS_2: 0,
		Battle.BattleType.FFA_SOLO_3: 0,
	}
	
	var battles_number = battles.size()
	
	for battle in battles:
		match battle.battle_type:
			Battle.BattleType.VS_1: battle_types_number[Battle.BattleType.VS_1] += 1
			Battle.BattleType.VS_2: battle_types_number[Battle.BattleType.VS_2] += 1
			Battle.BattleType.FFA_SOLO_3: battle_types_number[Battle.BattleType.FFA_SOLO_3] += 1
	
	var tables_node: Node3D
	var player_left_node: Node3D
	match battles_number:
		1:
			if battle_types_number[Battle.BattleType.VS_1] == 1:
				player_left_node = %"PlayersLeft_2"
				tables_node = %"1_1v1"
			elif battle_types_number[Battle.BattleType.VS_2] == 1:
				player_left_node = %"PlayersLeft_4"
				tables_node = %"1_2v2"
			elif battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_3"
				tables_node = %"1_ffa3"
		2:
			if battle_types_number[Battle.BattleType.VS_1] == 2:
				player_left_node = %"PlayersLeft_4"
				tables_node = %"2_1v1"
			elif battle_types_number[Battle.BattleType.VS_2] == 2:
				player_left_node = %"PlayersLeft_8"
				tables_node = %"2_2v2"
		4:
			if battle_types_number[Battle.BattleType.VS_1] == 4:
				player_left_node = %"PlayersLeft_8"
				tables_node = %"4_1v1"
	
	_init_tables(tables_node, battles)
	player_left_node.show()
	Utils.recursive_show(tables_node)
	show()

# ============================== Private functions ==============================

func _init_tables(tables_node: Node3D, battles: Array[Battle]) -> void:
	var tables = tables_node.find_children("", "Table", true, false)
	if tables.is_empty():
		printerr("TavernCenter: There is no tables node corresponding to this battles combination")
		return
	
	var battles_duplicate: Array[Battle] = battles.duplicate()
	for table_raw in tables:
		var table: Table = table_raw
		for battle in battles_duplicate:
			if battle.battle_type == table.battle_type:
				table.connect_to_players(battle.players)
				battles_duplicate.erase(battle)
				break

































 
