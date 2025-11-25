class_name EntityBDSRegistry
extends Resource

signal new_bds_added(bds: BattleDataStat)

var entity_name: String
var data_stat_dictionaries: Dictionary[BattleDataStat.Type, BattleDataStatDictionary]

class BattleDataStatDictionary extends Resource:
	var battle_data_stats: Dictionary[StringName, BattleDataStat]
	var _new_bds_added_signal: Signal
	var _bds_type: BattleDataStat.Type
	
	func _init(bds_type: BattleDataStat.Type, new_bds_added_signal: Signal) -> void:
		_bds_type = bds_type
		_new_bds_added_signal = new_bds_added_signal
	
	func register_action(action_id: StringName, action_type: Utils.ActionType, value: float, _is_critical: bool) -> void:
		if not battle_data_stats.has(action_id):
			battle_data_stats[action_id] = BattleDataStat.new(action_id, _bds_type)
			_new_bds_added_signal.emit(battle_data_stats[action_id])
		battle_data_stats[action_id].register_action(action_type, value)



#region ============================== Node base functions ==============================
func _init(ename: String) -> void:
	entity_name = ename
	for bds_type: BattleDataStat.Type in BattleDataStat.Type.values():
		data_stat_dictionaries[bds_type] = BattleDataStatDictionary.new(bds_type, new_bds_added)
#endregion



# 1. Dispatch between each BattleDataStat.Type (DAMAGE_DONE / HEAL_DONE / DAMAGE_RECEIVED / etc...) .data_stat_dictionaries (DataStatDictionary)
# 2. Dispatch between each action name (Auto attack / Meteor / Shroom / etc...) DataStatDictionary.battle_data_stats (BattleDataStat)
# 3. Dispatch between each Utils.ActionType (DAMAGE_PHYSICAL / DAMAGE_MAGICAL / HEAL / STUN / STACK_POISON / etc...) BattleDataStat.action_meters (float)
#region ============================== Public functions ==============================
func register_action(action_id: StringName, action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
	var bds_type: BattleDataStat.Type = BattleDataStat.action_type_to_battle_data_stat_type(action_type, BattleDataStat.MetaType.ACTION)
	data_stat_dictionaries[bds_type].register_action(action_id, action_type, value, is_critical)


func register_interaction(action_id: StringName, action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
	var bds_type: BattleDataStat.Type = BattleDataStat.action_type_to_battle_data_stat_type(action_type, BattleDataStat.MetaType.INTERACTION)
	data_stat_dictionaries[bds_type].register_action(action_id, action_type, value, is_critical)
#endregion
