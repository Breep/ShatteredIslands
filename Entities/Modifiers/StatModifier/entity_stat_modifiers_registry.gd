class_name EntityStatModifiersRegistry
extends Resource

class StatModifierDictionary extends Resource:
	var _stat_type: EntityStats.StatType
	var _modifiers: Dictionary[StringName, StatModifier]
	var _modifiers_per_action_type: Dictionary[Utils.ActionType, Dictionary]
	var _entity_stats_ref: EntityStats
	var _entity_base_stats_ref: EntityStats

	func setup(stat_type: EntityStats.StatType, entity_stat_ref: EntityStats, entity_base_stats_ref: EntityStats) -> void:
		_stat_type = stat_type
		_entity_stats_ref = entity_stat_ref
		_entity_base_stats_ref = entity_base_stats_ref
		for action_type: Utils.ActionType in Utils.get_all_actions():
			_modifiers_per_action_type[action_type] = {}


	func recompute_stats() -> void:
		_recompute_stats()


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
		else:
			if not _modifiers.has(modifier_id):
				Verbose.error("Unregister - Unknown stat modifier | " + modifier_id + " | " + str(_stat_type), Verbose.Category.STAT_MODIFIER)
				return
			_modifiers.erase(modifier_id)
		
		_recompute_stats()


	func auto_cleanup() -> void:
		if _is_multiple_stats():
			for action_type: Utils.ActionType in _modifiers_per_action_type.keys():
				for modifier: StatModifier in _modifiers_per_action_type[action_type].values().duplicate():
					if modifier.auto_cleanup:
						Verbose.debug("Auto cleaning | " + modifier.id, Verbose.Category.STAT_MODIFIER)
						_modifiers_per_action_type[action_type].erase(modifier.id)
		else:
			for modifier: StatModifier in _modifiers.values().duplicate():
				if modifier.auto_cleanup:
					Verbose.debug("Auto cleaning | " + modifier.id, Verbose.Category.STAT_MODIFIER)
					_modifiers.erase(modifier.id)

	# ============================== Private functions ==============================

	func _recompute_stats() -> void:
		Verbose.trace("_recompute_stats()", Verbose.Category.STAT_MODIFIER)
		if _is_multiple_stats():
			_recompute_multiple_stats()
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


	func _recompute_multiple_stats() -> void:
		for action_type: Utils.ActionType in Utils.get_all_actions():
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

# ============================== Export - Entity stats ==============================

var _entity_stats: EntityStats
var _entity_base_stats: EntityStats

# ============================== Private variables ==============================

var _stats_modifiers_dictionaries: Dictionary[EntityStats.StatType, StatModifierDictionary]

# ============================== Node base functions ==============================

func _init(base_stats: EntityStats, current_stats: EntityStats) -> void:
	# Single stats
	_stats_modifiers_dictionaries[EntityStats.StatType.HEALTH_MAX] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.HEALTH] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MANA_MAX] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MANA] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MANA_REGEN] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AD] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AA_SPEED] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.ATTACK_RANGE] = StatModifierDictionary.new()
	
	# Multiple stats
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_CHANCE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_MULT] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.RESISTANCE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.VULNERABILITY] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.DODGE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.STRENGTH] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.WEAKNESS] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_RESISTANCE] = StatModifierDictionary.new()
	
	_entity_base_stats = base_stats
	_entity_stats = current_stats
	_entity_stats.auto_attack_type = _entity_base_stats.auto_attack_type
	_entity_base_stats.has_been_reset.connect(_on_entity_base_stats_has_been_reset)
	for stat_type: EntityStats.StatType in _stats_modifiers_dictionaries.keys():
		_stats_modifiers_dictionaries[stat_type].setup(stat_type, _entity_stats, _entity_base_stats)
		_stats_modifiers_dictionaries[stat_type].recompute_stats()
	GameManager.game_state_changed.connect(_on_game_manager_game_state_changed)

# ============================== Public functions ==============================

func register_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].register_modifier(stat_modifier)


func update_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].update_modifier(stat_modifier)


func unregister_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].unregister_modifier(stat_modifier)


func remove_modifier(stat_type: EntityStats.StatType, id: String, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> void:
	var dummy := StatModifier.new()
	dummy.stat_type = stat_type
	dummy.id = id
	dummy.action_type = action_type
	unregister_modifier(dummy)

# ============================== Private functions ==============================

func _auto_cleanup_all() -> void:
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		smd.auto_cleanup()
		smd.recompute_stats()

# ============================== Callbacks ==============================

func _on_entity_base_stats_has_been_reset() -> void:
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		smd.recompute_stats()


func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.ENDING_ROUND:
			_auto_cleanup_all()
