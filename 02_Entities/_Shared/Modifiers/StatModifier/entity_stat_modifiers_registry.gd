# EntityStatModifiersRegistry — applique l'ensemble des StatModifier à une entité.
# Maintient un dict de modifiers par StatType (single = flat dict, multi = dict par ActionType),
# recompute la stat finale (`(base + sum(ADD)) * (1 + sum(MULT))`) et propage vers `stats`.
# Les Mono alias (ARMOR/MR/PR) sont reroutées en interne vers M_RESISTANCE[action].
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
		if EntityStats.is_multi_stat(_stat_type):
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
		if EntityStats.is_multi_stat(_stat_type):
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


	# Tous les modifiers stockés pour cette stat (toutes action_types confondues
	# pour les multi-stats). Utilisé par SummonModifiersRegistry pour itérer.
	func get_all_modifiers() -> Array[StatModifier]:
		var result: Array[StatModifier] = []
		if EntityStats.is_multi_stat(_stat_type):
			for action_type: Utils.ActionType in _modifiers_per_action_type.keys():
				for modifier: StatModifier in _modifiers_per_action_type[action_type].values():
					result.append(modifier)
		else:
			for modifier: StatModifier in _modifiers.values():
				result.append(modifier)
		return result


	# Valeur du modifier d'id donné pour cette stat (0.0 s'il n'existe pas).
	func get_modifier_value(id: StringName, action_type: Utils.ActionType) -> float:
		var modifier: StatModifier
		if EntityStats.is_multi_stat(_stat_type):
			modifier = _modifiers_per_action_type[action_type].get(id)
		else:
			modifier = _modifiers.get(id)
		return modifier.value if modifier != null else 0.0

	# ============================== Private functions ==============================

	func _recompute_stats() -> void:
		if _entity_base_stats_ref == null:
			return # TODO A virer avec le refacto des modifiers registry
		Verbose.trace("_recompute_stats()", Verbose.Category.STAT_MODIFIER)
		if EntityStats.is_multi_stat(_stat_type):
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
		var base_stat: float = _entity_base_stats_ref.get_stat(_stat_type)
		var new_stat: float = (base_stat + add) * (1.0 + mul)
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
			var base_stat: float = _entity_base_stats_ref.get_stat(_stat_type, action_type)
			var new_stat: float = (base_stat + add) * (1.0 + mul)
			_entity_stats_ref.update_stat(_stat_type, new_stat, action_type)


# ============================== Export - Entity stats ==============================

var _entity_stats: EntityStats
var _entity_base_stats: EntityStats

# ============================== Private variables ==============================

var _stats_modifiers_dictionaries: Dictionary[EntityStats.StatType, StatModifierDictionary]

# ============================== Node base functions ==============================

func _init(stats: EntityStats) -> void:
	# Mono pure (single)
	_stats_modifiers_dictionaries[EntityStats.StatType.HEALTH_MAX] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MANA_MAX] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MANA_REGEN] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AD] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AS] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AP] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AR] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.MS] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.SCALE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.AOE_SIZE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_RESISTANCE] = StatModifierDictionary.new()

	# Mono avec Multi sœur (single)
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_CHANCE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.CRIT_MULT] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.DODGE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.LIFESTEAL] = StatModifierDictionary.new()

	# Multi only (per-action)
	_stats_modifiers_dictionaries[EntityStats.StatType.M_CRIT_CHANCE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_CRIT_MULT] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_DODGE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_LIFESTEAL] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_POWER] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_FRAGILITY] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_RESISTANCE] = StatModifierDictionary.new()
	_stats_modifiers_dictionaries[EntityStats.StatType.M_EXPOSURE] = StatModifierDictionary.new()

	_entity_stats = stats

# ============================== Public functions ==============================

func update_base_stats(base_stats: EntityStats) -> void:
	if base_stats == null:
		Verbose.warn("No base stats for entity - Using default base stats", Verbose.Category.STAT_MODIFIER)
		base_stats = EntityStats.new()
	_entity_base_stats = base_stats
	_entity_stats.auto_attack_type = base_stats.auto_attack_type
	recompute_all()
	_entity_stats.reset_from_self()

func register_modifier(stat_modifier: StatModifier) -> void:
	_normalize_alias(stat_modifier)
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if not _stats_modifiers_dictionaries.has(stat_type):
		Verbose.error("Cannot register modifier for stat type " + str(stat_type) + " because it is not managed by the registry", Verbose.Category.STAT_MODIFIER)
		return
	_stats_modifiers_dictionaries[stat_type].register_modifier(stat_modifier)


func unregister_modifier(stat_modifier: StatModifier) -> void:
	_normalize_alias(stat_modifier)
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	if not _stats_modifiers_dictionaries.has(stat_type):
		Verbose.error("Cannot unregister modifier for stat type " + str(stat_type) + " because it is not managed by the registry", Verbose.Category.STAT_MODIFIER)
		return
	_stats_modifiers_dictionaries[stat_type].unregister_modifier(stat_modifier)


func remove_modifier(stat_type: EntityStats.StatType, id: String, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> void:
	var dummy := StatModifier.new()
	dummy.stat_type = stat_type
	dummy.id = id
	dummy.action_type = action_type
	unregister_modifier(dummy)


# Valeur courante du modifier d'id donné sur une stat (résout les alias ARMOR/MR/PR).
# Retourne 0.0 si aucun modifier de cet id n'est appliqué.
func get_modifier_value(stat_type: EntityStats.StatType, id: StringName, action_type: Utils.ActionType = Utils.ActionType.DAMAGE_PHYSICAL) -> float:
	var resolved: Dictionary = EntityStats.resolve_alias(stat_type)
	if not resolved.is_empty():
		stat_type = resolved["stat_type"]
		action_type = resolved["action_type"]
	if not _stats_modifiers_dictionaries.has(stat_type):
		return 0.0
	return _stats_modifiers_dictionaries[stat_type].get_modifier_value(id, action_type)


func recompute_all() -> void:
	for stat_type: EntityStats.StatType in _stats_modifiers_dictionaries.keys():
		_stats_modifiers_dictionaries[stat_type].setup(stat_type, _entity_stats, _entity_base_stats)
		_stats_modifiers_dictionaries[stat_type].recompute_stats()


# Tous les StatModifier stockés, toutes stats confondues. Utilisé par
# SummonModifiersRegistry.apply_to pour cloner et propager vers les summons.
func get_all_modifiers() -> Array[StatModifier]:
	var result: Array[StatModifier] = []
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		result.append_array(smd.get_all_modifiers())
	return result

# ============================== Private functions ==============================

# Si stat_type est un alias (ARMOR/MR/PR), réécrit le modifier vers M_RESISTANCE[action_alias].
func _normalize_alias(stat_modifier: StatModifier) -> void:
	var resolved: Dictionary = EntityStats.resolve_alias(stat_modifier.stat_type)
	if resolved.is_empty(): return
	stat_modifier.stat_type = resolved["stat_type"]
	stat_modifier.action_type = resolved["action_type"]
