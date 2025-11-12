class_name EntityStatsManager
extends Node

# ============================== Export - Entity stats ==============================

@export var _entity_stats: EntityStats
@export var _entity_base_stats: EntityStats

# ============================== Private variables ==============================

@onready var _stats_modifiers_dictionaries: Dictionary [EntityStats.StatType, StatModifierDictionary] = {
	EntityStats.StatType.HEALTH_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.HEALTH: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.MANA: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_REGEN: StatModifierDictionary.new(),
	EntityStats.StatType.AD: StatModifierDictionary.new(),
	EntityStats.StatType.AA_SPEED: StatModifierDictionary.new(),
	EntityStats.StatType.CRIT_CHANCE: StatModifierDictionary.new(),
	EntityStats.StatType.CRIT_MULT: StatModifierDictionary.new(),
	EntityStats.StatType.RESISTANCE: StatModifierDictionary.new(),
}

# ============================== Node base functions ==============================

func _ready() -> void:
	_entity_base_stats.has_been_reset.connect(_on_entity_base_stats_has_been_reset)
	for stat_type: EntityStats.StatType in _stats_modifiers_dictionaries.keys():
		_stats_modifiers_dictionaries[stat_type].setup(stat_type, _entity_stats, _entity_base_stats)

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

# ============================== Callbacks ==============================

func _on_entity_base_stats_has_been_reset() -> void:
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		smd.recompute_stats()
