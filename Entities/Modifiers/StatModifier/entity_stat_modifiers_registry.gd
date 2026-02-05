class_name EntityStatModifiersRegistry
extends Resource

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
