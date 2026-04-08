class_name EntityBDSRegistry
extends Resource

signal new_bds_added(bds: BattleDataStat)

var _entity_owner: Entity
var data_stat_dictionaries: Dictionary[BattleDataStat.Type, BattleDataStatDictionary]
var _summon_callables: Dictionary = {}

class BattleDataStatDictionary extends Resource:
	var battle_data_stats: Dictionary[StringName, BattleDataStat]
	var _new_bds_added_signal: Signal
	var _bds_type: BattleDataStat.Type
	
	func _init(bds_type: BattleDataStat.Type, new_bds_added_signal: Signal) -> void:
		_bds_type = bds_type
		_new_bds_added_signal = new_bds_added_signal
	
	func register_action(action_id: StringName, action_type: Utils.ActionType, value: float, _is_critical: bool) -> void:
		Verbose.trace("Register action "+action_id + " " + str(value),Verbose.Category.BDS_REGISTERY)
		if not battle_data_stats.has(action_id):
			battle_data_stats[action_id] = BattleDataStat.new(action_id, _bds_type)
			_new_bds_added_signal.emit(battle_data_stats[action_id])
		battle_data_stats[action_id].register_action(action_type, value)


#region ============================== Node base functions ==============================
func _init(entity: Entity) -> void:
	_entity_owner = entity
	for bds_type: BattleDataStat.Type in BattleDataStat.Type.values():
		data_stat_dictionaries[bds_type] = BattleDataStatDictionary.new(bds_type, new_bds_added)
	_entity_owner.action_done.connect(_on_entity_owner_action_done)
	_entity_owner.action_received.connect(_on_entity_owner_action_received)
#endregion



# 1. Dispatch between each BattleDataStat.Type (DAMAGE_DONE / HEAL_DONE / DAMAGE_RECEIVED / etc...) .data_stat_dictionaries (DataStatDictionary)
# 2. Dispatch between each action name (Auto attack / Meteor / Shroom / etc...) DataStatDictionary.battle_data_stats (BattleDataStat)
# 3. Dispatch between each Utils.ActionType (DAMAGE_PHYSICAL / DAMAGE_MAGICAL / HEAL / STUN / STACK_POISON / etc...) BattleDataStat.action_meters (float)
#region ============================== Public functions ==============================
func register_summon(summon: Entity) -> void:
	var callable := _on_summon_action_done.bind(summon.entity_name)
	_summon_callables[summon] = callable
	summon.action_done.connect(callable)
	summon.tree_exiting.connect(unregister_summon.bind(summon), CONNECT_ONE_SHOT)


func unregister_summon(summon: Entity) -> void:
	if summon in _summon_callables:
		summon.action_done.disconnect(_summon_callables[summon])
		_summon_callables.erase(summon)


func register_action(action_id: StringName, action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
	var bds_type: BattleDataStat.Type = BattleDataStat.action_type_to_battle_data_stat_type(action_type, BattleDataStat.Direction.SENT)
	data_stat_dictionaries[bds_type].register_action(action_id, action_type, value, is_critical)


func register_action_received(action_id: StringName, action_type: Utils.ActionType, value: float, is_critical: bool) -> void:
	var bds_type: BattleDataStat.Type = BattleDataStat.action_type_to_battle_data_stat_type(action_type, BattleDataStat.Direction.RECEIVED)
	data_stat_dictionaries[bds_type].register_action(action_id, action_type, value, is_critical)
#endregion


#region ============================== Callbacks ==============================
func _on_entity_owner_action_done(_target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	register_action(action_id, action_type, value, is_critical)


func _on_entity_owner_action_received(_source: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool) -> void:
	register_action_received(action_id, action_type, value, is_critical)


func _on_summon_action_done(_target: Entity, action_type: Utils.ActionType, action_id: StringName, value: float, is_critical: bool, summon_name: String) -> void:
	var prefixed_id: StringName = StringName(summon_name + "_" + action_id)
	register_action(prefixed_id, action_type, value, is_critical)
#endregion
