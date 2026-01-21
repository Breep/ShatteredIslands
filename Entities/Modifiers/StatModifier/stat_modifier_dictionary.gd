class_name StatModifierDictionary
extends Resource

# ============================== Private variables ==============================

var _stat_type: EntityStats.StatType
var _modifiers: Dictionary[StringName, StatModifier]
var _modifiers_per_action_type: Dictionary[Utils.ActionType, Dictionary]

var _entity_stats_ref: EntityStats
var _entity_base_stats_ref: EntityStats

# ============================== Public functions ==============================

func setup(stat_type: EntityStats.StatType, entity_stat_ref: EntityStats, entity_base_stats_ref: EntityStats) -> void:
	_stat_type = stat_type
	_entity_stats_ref = entity_stat_ref
	_entity_base_stats_ref = entity_base_stats_ref
	for action_type: Utils.ActionType in Utils.get_all_actions():
		_modifiers_per_action_type[action_type] = {}


func recompute_stats(for_action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL, is_targeted: bool = false) -> void:
	_recompute_stats(for_action_type, is_targeted)


func register_modifier(stat_modifier: StatModifier) -> void:
	Verbose.debug("register_modifier() | " + stat_modifier.id, Verbose.Category.STAT_MODIFIER)
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		Verbose.error("Trying to register a modifier for an other stat type |" + str(stat_type) + " | " + str(_stat_type), Verbose.Category.STAT_MODIFIER)
		return
	
	var modifier_id: String = stat_modifier.id
	if _modifiers.has(modifier_id):
		Verbose.error("Register - Already known stat modifier | id=" + modifier_id + " | " + str(_stat_type), Verbose.Category.STAT_MODIFIER)
		return
	
	if _is_multiple_stats():
		_modifiers_per_action_type[stat_modifier.action_type][modifier_id] = stat_modifier
		_recompute_stats(stat_modifier.action_type, true)
	else:
		_modifiers[modifier_id] = stat_modifier
		_recompute_stats()


func update_modifier(stat_modifier: StatModifier) -> void:
	Verbose.debug("update_modifier() | " + stat_modifier.id, Verbose.Category.STAT_MODIFIER)
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		Verbose.error("Trying to update a modifier for an other stat type | " + str(stat_type) + " | " + str(_stat_type), Verbose.Category.STAT_MODIFIER)
		return
	
	var modifier_id: String = stat_modifier.id
	if _is_multiple_stats():
		_modifiers_per_action_type[stat_modifier.action_type][modifier_id] = stat_modifier
		_recompute_stats(stat_modifier.action_type, true)
	else:
		_modifiers[modifier_id] = stat_modifier
		_recompute_stats()


func unregister_modifier(stat_modifier: StatModifier) -> void:
	Verbose.debug("unregister_modifier() | " + stat_modifier.id, Verbose.Category.STAT_MODIFIER)
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if stat_type != _stat_type:
		Verbose.error("Trying to unregister a modifier for an other stat type | " + str(stat_type) + str(_stat_type), Verbose.Category.STAT_MODIFIER)
		return
	
	var modifier_id: String = stat_modifier.id
	if _is_multiple_stats():
		if not _modifiers_per_action_type[stat_modifier.action_type].has(modifier_id):
			Verbose.error("Unregister - Unknown multiple stats modifier | " + str(modifier_id) + str(_stat_type), Verbose.Category.STAT_MODIFIER)
			return
		_modifiers_per_action_type[stat_modifier.action_type].erase(modifier_id)
		_recompute_stats(stat_modifier.action_type, true)
	else:
		if not _modifiers.has(modifier_id):
			Verbose.error("Unregister - Unknown stat modifier | " + modifier_id + " | " + str(_stat_type), Verbose.Category.STAT_MODIFIER)
			return
		_modifiers.erase(modifier_id)
		_recompute_stats()


func auto_cleanup() -> void:
	if _is_multiple_stats():
		var actions_to_recompute: Array[Utils.ActionType] = []
		for action_type: Utils.ActionType in _modifiers_per_action_type.keys():
			var dirty: bool = false
			for modifier: StatModifier in _modifiers_per_action_type[action_type].values().duplicate():
				if modifier.auto_cleanup:
					Verbose.debug("Auto cleaning | " + modifier.id, Verbose.Category.STAT_MODIFIER)
					_modifiers_per_action_type[action_type].erase(modifier.id)
					dirty = true
			if dirty:
				actions_to_recompute.append(action_type)
		
		for action_type in actions_to_recompute:
			_recompute_stats(action_type, true)
	else:
		var dirty: bool = false
		for modifier: StatModifier in _modifiers.values().duplicate():
			if modifier.auto_cleanup:
				Verbose.debug("Auto cleaning | " + modifier.id, Verbose.Category.STAT_MODIFIER)
				_modifiers.erase(modifier.id)
				dirty = true
		if dirty:
			_recompute_stats()

# ============================== Private functions ==============================

func _recompute_stats(for_action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL, is_targeted: bool = false) -> void:
	Verbose.trace("_recompute_stats()", Verbose.Category.STAT_MODIFIER)
	if _is_multiple_stats():
		_recompute_multiple_stats(for_action_type, is_targeted)
	else:
		_recompute_single_stats()


func _recompute_single_stats() -> void:
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


func _recompute_multiple_stats(for_action_type: Utils.ActionType, is_targeted: bool) -> void:
	if is_targeted:
		_recompute_specific_action_stat(for_action_type)
	else:
		for action_type: Utils.ActionType in Utils.get_all_actions():
			_recompute_specific_action_stat(action_type)


func _recompute_specific_action_stat(action_type: Utils.ActionType) -> void:
	var mods: Dictionary = _modifiers_per_action_type[action_type]
	var add: float = 0.0
	var mul: float = 0.0
	for modifier: StatModifier in mods.values():
		if modifier.calc_type == StatModifier.CalcType.ADD:
			add += modifier.value
		elif modifier.calc_type == StatModifier.CalcType.MULT:
			mul += modifier.value
	var base_stat = _entity_base_stats_ref.get_stat(_stat_type, action_type)
	var new_stat = (base_stat + add) * (1.0 + mul)
	_entity_stats_ref.update_stat(_stat_type, new_stat, action_type)


func _is_multiple_stats() -> bool:
	return _stat_type == EntityStats.StatType.CRIT_CHANCE \
			or _stat_type == EntityStats.StatType.CRIT_MULT \
			or _stat_type == EntityStats.StatType.RESISTANCE \
			or _stat_type == EntityStats.StatType.VULNERABILITY \
			or _stat_type == EntityStats.StatType.DODGE \
			or _stat_type == EntityStats.StatType.CRIT_RESISTANCE \
			or _stat_type == EntityStats.StatType.STRENGTH \
			or _stat_type == EntityStats.StatType.WEAKNESS
