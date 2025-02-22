class_name TavernCenter
extends Node3D

@onready var _table_1_1v1: Node3D = $"1/Table_1v1"

var _battle_types = {
	Battle.BattleType.VS_1: 0,
	Battle.BattleType.VS_2: 0,
	Battle.BattleType.VS_3: 0,
	Battle.BattleType.VS_4: 0,
	Battle.BattleType.FFA_SOLO_3: 0,
	Battle.BattleType.FFA_SOLO_4: 0,
	Battle.BattleType.FFA_SOLO_5: 0,
	Battle.BattleType.FFA_SOLO_6: 0,
	Battle.BattleType.FFA_SOLO_7: 0,
	Battle.BattleType.FFA_SOLO_8: 0,
	Battle.BattleType.FFA_DUO_6: 0,
	Battle.BattleType.FFA_DUO_8: 0,
}

func _ready() -> void:
	_table_1_1v1.hide()


func put_tables_according_to_battles(battles: Array[Battle]) -> void:
	var battle_number = battles.size()
	
	for battle in battles:
		match battle.battle_type:
			Battle.BattleType.VS_1: _battle_types[Battle.BattleType.VS_1] += 1
			Battle.BattleType.VS_2: _battle_types[Battle.BattleType.VS_2] += 1
			Battle.BattleType.VS_3: _battle_types[Battle.BattleType.VS_3] += 1
			Battle.BattleType.VS_4: _battle_types[Battle.BattleType.VS_4] += 1
			Battle.BattleType.FFA_SOLO_3: _battle_types[Battle.BattleType.FFA_SOLO_3] += 1
			Battle.BattleType.FFA_SOLO_4: _battle_types[Battle.BattleType.FFA_SOLO_4] += 1
			Battle.BattleType.FFA_SOLO_5: _battle_types[Battle.BattleType.FFA_SOLO_5] += 1
			Battle.BattleType.FFA_SOLO_6: _battle_types[Battle.BattleType.FFA_SOLO_6] += 1
			Battle.BattleType.FFA_SOLO_7: _battle_types[Battle.BattleType.FFA_SOLO_7] += 1
			Battle.BattleType.FFA_SOLO_8: _battle_types[Battle.BattleType.FFA_SOLO_8] += 1
			Battle.BattleType.FFA_DUO_6: _battle_types[Battle.BattleType.FFA_DUO_6] += 1
			Battle.BattleType.FFA_DUO_8: _battle_types[Battle.BattleType.FFA_DUO_8] += 1
	
	match battle_number:
		1:
			if _battle_types[Battle.BattleType.VS_1] == 1:
				_table_1_1v1.show()
	
	

































 
