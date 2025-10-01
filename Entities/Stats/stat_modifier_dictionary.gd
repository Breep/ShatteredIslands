class_name StatModifierDictionary
extends Resource

# ============================== Private variables ==============================

var _stat_type: EntityStats.StatType
var _modifiers: Dictionary[StringName, StatModifier]

var _entity_stats_ref: EntityStats
var _entity_base_stats_ref: EntityStats

# ============================== Public functions ==============================

func setup(stat_type: EntityStats.StatType, entity_stat_ref: EntityStats, entity_base_stats_ref: EntityStats) -> void:
	_stat_type = stat_type
	_entity_stats_ref = entity_stat_ref
	_entity_base_stats_ref = entity_base_stats_ref


func register_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		printerr("StatModifierDictionary: register_modifier() - Trying to register a modifier for an other stat type \"", stat_type, "\" [", _stat_type, "]")
		return
	
	var modifier_id: String = stat_modifier.id
	if _modifiers.has(modifier_id):
		printerr("StatModifierDictionary: register_modifier() - already known stat modifier \"", modifier_id, "\" [", _stat_type, "]")
		return
	
	_modifiers[modifier_id] = stat_modifier
	_recompute_stats()


func update_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		printerr("StatModifierDictionary: register_modifier() - Trying to update a modifier for an other stat type \"", stat_type, "\" [", _stat_type, "]")
		return
	
	var modifier_id: String = stat_modifier.id
	_modifiers[modifier_id] = stat_modifier
	_recompute_stats()


func unregister_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		printerr("StatModifierDictionary: register_modifier() - Trying to unregister a modifier for an other stat type \"", stat_type, "\" [", _stat_type, "]")
		return
	
	var modifier_id: String = stat_modifier.id
	if not _modifiers.has(modifier_id):
		printerr("EntityStatsManager: unregister_modifier() - unknown stat modifier \"", modifier_id, "\" [", _stat_type, "]")
		return
	
	_modifiers.erase(modifier_id)
	_recompute_stats()

# ============================== Private functions ==============================

func _recompute_stats() -> void:
	var add: float = 0.0
	var mul: float = 0.0
	for modifier: StatModifier in _modifiers.values():
		if modifier.calc_type == StatModifier.CalcType.ADD:
			add += modifier.value
		elif modifier.calc_type == StatModifier.CalcType.MULT:
			mul += modifier.value
	var base_stat = _entity_base_stats_ref.get_stat(_stat_type)
	var new_stat = (base_stat + add) * (1.0 + mul)
	_entity_stats_ref.update_stat(_stat_type, new_stat)
