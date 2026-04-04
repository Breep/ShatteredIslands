class_name TavernCenter
extends Node3D

# ============================== Private variables ==============================


# ============================== Local nodes ==============================

@export_group("Local nodes")
@export var _table_layouts: Array[TableLayout]

# ============================== Node base functions ==============================

func _ready() -> void:
	for table_layout in _table_layouts:
		table_layout.set_inactive()

# ============================== Public functions ==============================

func cleanup_table_layouts() -> void:
	for table_layout: TableLayout in _table_layouts:
		table_layout.cleanup_tables()

# TODO Rework cette monstruosité: l'idée sera d'avoir des spawn de tables, de définir si une table a besoin d'un espace plus grand que d'autres etc etc
func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	for table_layout in _table_layouts:
		table_layout.set_inactive()
	
	var battle_types_number = {
		Battle.BattleType.VS_1: 0,
		Battle.BattleType.VS_2: 0,
		Battle.BattleType.VS_3: 0,
		Battle.BattleType.VS_4: 0,
		Battle.BattleType.FFA_SOLO_3: 0,
	}

	var battles_number = battles.size()

	for battle in battles:
		match battle.battle_type:
			Battle.BattleType.VS_1: battle_types_number[Battle.BattleType.VS_1] += 1
			Battle.BattleType.VS_2: battle_types_number[Battle.BattleType.VS_2] += 1
			Battle.BattleType.VS_3: battle_types_number[Battle.BattleType.VS_3] += 1
			Battle.BattleType.VS_4: battle_types_number[Battle.BattleType.VS_4] += 1
			Battle.BattleType.FFA_SOLO_3: battle_types_number[Battle.BattleType.FFA_SOLO_3] += 1

	var table_layout: TableLayout
	var player_left_node: Node3D
	match battles_number:
		1:
			if battle_types_number[Battle.BattleType.VS_1] == 1:
				player_left_node = %"PlayersLeft_2"
				table_layout = %"1_1v1"
			elif battle_types_number[Battle.BattleType.VS_2] == 1:
				player_left_node = %"PlayersLeft_4"
				table_layout = %"1_2v2"
			elif battle_types_number[Battle.BattleType.VS_3] == 1:
				player_left_node = %"PlayersLeft_6"
				table_layout = %"1_3v3"
			elif battle_types_number[Battle.BattleType.VS_4] == 1:
				player_left_node = %"PlayersLeft_8"
				table_layout = %"1_4v4"
			elif battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_3"
				table_layout = %"1_ffa3"
		2:
			if battle_types_number[Battle.BattleType.VS_1] == 2:
				player_left_node = %"PlayersLeft_4"
				table_layout = %"2_1v1"
			elif battle_types_number[Battle.BattleType.VS_2] == 2:
				player_left_node = %"PlayersLeft_8"
				table_layout = %"2_2v2"
			elif battle_types_number[Battle.BattleType.VS_1] == 1 and battle_types_number[Battle.BattleType.VS_2] == 1:
				player_left_node = %"PlayersLeft_6"
				table_layout = %"1_2v2_1_1v1"
			elif battle_types_number[Battle.BattleType.VS_3] == 1 and battle_types_number[Battle.BattleType.VS_1] == 1:
				player_left_node = %"PlayersLeft_8"
				table_layout = %"1_3v3_1_1v1"
			elif battle_types_number[Battle.BattleType.VS_2] == 1 and battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_7"
				table_layout = %"1_2v2_1_ffa3"
			elif battle_types_number[Battle.BattleType.VS_1] == 1 and battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_5"
				table_layout = %"1_1v1_1_ffa3"
		3:
			if battle_types_number[Battle.BattleType.VS_1] == 3:
				player_left_node = %"PlayersLeft_6"
				table_layout = %"3_1v1"
			elif battle_types_number[Battle.BattleType.VS_1] == 2 and battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_7"
				table_layout = %"2_1v1_1_ffa3"
		4:
			if battle_types_number[Battle.BattleType.VS_1] == 4:
				player_left_node = %"PlayersLeft_8"
				table_layout = %"4_1v1"
	
	player_left_node.show()
	table_layout.set_active(battles)






























 
