class_name EntityStatsManager
extends Node

# ============================== Export - Entity stats ==============================

@export var _entity_stats: EntityStats
@export var _entity_base_stats: EntityStats

# ============================== Private variables ==============================

@onready var _stats_modifiers_dictionaries: Dictionary [EntityStats.StatType, StatModifierDictionary] = {
	# Single stats
	EntityStats.StatType.HEALTH_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.HEALTH: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_MAX: StatModifierDictionary.new(),
	EntityStats.StatType.MANA: StatModifierDictionary.new(),
	EntityStats.StatType.MANA_REGEN: StatModifierDictionary.new(),
	EntityStats.StatType.AD: StatModifierDictionary.new(),
	EntityStats.StatType.AA_SPEED: StatModifierDictionary.new(),
	
	# Multiple stats
	EntityStats.StatType.CRIT_CHANCE: StatModifierDictionary.new(),
	EntityStats.StatType.CRIT_MULT: StatModifierDictionary.new(),
	EntityStats.StatType.RESISTANCE: StatModifierDictionary.new(),
	EntityStats.StatType.VULNERABILITY: StatModifierDictionary.new(),
	EntityStats.StatType.DODGE: StatModifierDictionary.new(),
	EntityStats.StatType.STRENGHT: StatModifierDictionary.new(),
	EntityStats.StatType.WEAKNESS: StatModifierDictionary.new(),
}

# ============================== Node base functions ==============================

func _ready() -> void:
	_entity_base_stats.has_been_reset.connect(_on_entity_base_stats_has_been_reset)
	for stat_type: EntityStats.StatType in _stats_modifiers_dictionaries.keys():
		_stats_modifiers_dictionaries[stat_type].setup(stat_type, _entity_stats, _entity_base_stats)
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

# ============================== Private functions ==============================

func _auto_cleanup_all() -> void:
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		smd.auto_cleanup()

# ============================== Callbacks ==============================

func _on_entity_base_stats_has_been_reset() -> void:
	for smd: StatModifierDictionary in _stats_modifiers_dictionaries.values():
		smd.recompute_stats()


func _on_game_manager_game_state_changed(game_state: Game.GameState) -> void:
	match game_state:
		Game.GameState.FIGHTING_FINISHED:
			_auto_cleanup_all()
