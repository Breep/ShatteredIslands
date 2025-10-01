class_name EntityStatsManager
extends Node

@export var _entity_stats: EntityStats
@export var _entity_base_stats: EntityStats

@onready var _stats_modifiers_dictionaries: Dictionary [EntityStats.StatType, StatModifierDictionary] = {
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

func _ready() -> void:
	for stat_type in _stats_modifiers_dictionaries.keys():
		_stats_modifiers_dictionaries[stat_type].setup(stat_type, _entity_stats, _entity_base_stats)


func register_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].register_modifier(stat_modifier)


func update_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].update_modifier(stat_modifier)


func unregister_modifier(stat_modifier: StatModifier) -> void:
	var stat_type: EntityStats.StatType = stat_modifier.stat_type
	_stats_modifiers_dictionaries[stat_type].unregister_modifier(stat_modifier)
