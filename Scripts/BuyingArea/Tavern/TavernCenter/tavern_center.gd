class_name TavernCenter
extends Node3D

# ============================== Private variables ==============================

var _battle_types_number = {
	Battle.BattleType.VS_1: 0,
	Battle.BattleType.VS_2: 0,
	Battle.BattleType.FFA_SOLO_3: 0,
}

# ============================== Local nodes ==============================

@onready var _hero_selection: Node3D = %HeroSelection # Main node of the Hero selection

@export var _hero_selection_spawns: Array[Node3D]

# ============================== Node base functions ==============================

func _ready() -> void:
	Utils.recursive_hide(self)
	
	for spawn in _hero_selection_spawns:
		for child in spawn.get_children():
			child.queue_free()

# ============================== Public functions ==============================

func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	var battles_number = battles.size()
	
	for battle in battles:
		match battle.battle_type:
			Battle.BattleType.VS_1: _battle_types_number[Battle.BattleType.VS_1] += 1
			Battle.BattleType.VS_2: _battle_types_number[Battle.BattleType.VS_2] += 1
			Battle.BattleType.FFA_SOLO_3: _battle_types_number[Battle.BattleType.FFA_SOLO_3] += 1
	
	var tables_node: Node3D
	var player_left_node: Node3D
	match battles_number:
		1:
			if _battle_types_number[Battle.BattleType.VS_1] == 1:
				player_left_node = %"PlayersLeft_2"
				tables_node = %"1_1v1"
			elif _battle_types_number[Battle.BattleType.VS_2] == 1:
				player_left_node = %"PlayersLeft_4"
				tables_node = %"1_2v2"
			elif _battle_types_number[Battle.BattleType.FFA_SOLO_3] == 1:
				player_left_node = %"PlayersLeft_3"
				tables_node = %"1_ffa3"
		2:
			if _battle_types_number[Battle.BattleType.VS_1] == 2:
				player_left_node = %"PlayersLeft_4"
				tables_node = %"2_1v1"
	
	_init_tables(tables_node, battles)
	player_left_node.show()
	Utils.recursive_show(tables_node)
	show()


func init_hero_selection(heroes: Array[Hero]) -> void:
	for i in heroes.size():
		var hero3D: Hero3D = heroes[i].model.instantiate()
		_hero_selection.add_child(hero3D)
		hero3D.global_position = _hero_selection_spawns[i].global_position
		hero3D.name = heroes[i].name
	_hero_selection.show()
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
				pass

































 
