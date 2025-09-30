class_name EntityStatsManager
extends Node

@onready var _stats_modifiers: Dictionary [EntityStats.StatType, StatModifierDictionary] = {
	EntityStats.StatType.HEALTH_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.HEALTH: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.MANA: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_REGEN: StatModifierDictionary.new(),
	EntityStats.StatType.AD: StatModifierDictionary.new(),
	EntityStats.StatType.AA_SPEED: StatModifierDictionary.new(),
	EntityStats.StatType.CRIT_CHANCE: StatModifierDictionary.new(),
	EntityStats.StatType.CRIT_MULT: StatModifierDictionary.new()
}


func register_modifier(stat_modifier: StatModifier) -> void:
	var type: EntityStats.StatType = stat_modifier.stat_type
	var key: String = stat_modifier.id
	if _stats_modifiers[type].has(key):
		printerr("EntityStatsManager: register_modifier() - already known stat modifier \"", key, "\" [", get_path(), "]")
		return
	_recompute_stats()


func update_modifier(key: String, stat_modifier: StatModifier) -> void:
	_recompute_stats()


func unregister_modifier(stat_modifier: StatModifier) -> void:
	var type: EntityStats.StatType = stat_modifier.stat_type
	var key: String = stat_modifier.id
	if not _stats_modifiers[type].has(key):
		printerr("EntityStatsManager: unregister_modifier() - unknown stat modifier \"", key, "\" [", get_path(), "]")
		return
	
	_recompute_stats()


func _recompute_stats() -> void:
	pass
