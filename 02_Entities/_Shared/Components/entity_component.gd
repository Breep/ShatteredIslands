class_name EntityComponent
extends Node

enum Type {
	MOVEMENT = 0,
	TARGET = 1,
	ALTERATIONS = 2,
	DAMAGE = 3,
	HEAL = 4,
	PROJECTILE = 5,
	SPELL = 6,
	SUMMON = 7,
	AUTO_ATTACK = 8,
	AUTO_ATTACK_PERIODIC_MODULE = 9,
	LABEL_POPUP_MODULE = 10,
	ANIMATION = 11,
	SPAWN_ANIMATION = 12,
	CLICKABLE = 13,
	DESPAWN = 14,
	DISPLAY_MODE = 15
}

static var _global_dodge_number: int = 0
static var _crit_check_number: int = -1

@export var _owner: Entity # Owner of the module

var _dodge_number: int = -1

func init(entity_owner: Entity) -> EntityComponent:
	_owner = entity_owner
	return self

func _ready() -> void:
	if _owner == null:
		printerr("Module: undef source [", get_path(), "]")


#region ============================== Private API ==============================
func _get_crit_multiplier(action_type: Utils.ActionType) -> Dictionary:
	var is_critical: bool = false
	var crit_chance: float = _owner.stats.get_effective_stat(EntityStats.StatType.CRIT_CHANCE, action_type)
	var crit_multiplier_percent: float = 0.0

	_crit_check_number += 1
	if Utils.is_randomize_modifier_active(crit_chance, _owner.battle_id, "crit_check_" + str(_crit_check_number)):
		is_critical = true
		crit_multiplier_percent = _owner.stats.get_effective_stat(EntityStats.StatType.CRIT_MULT, action_type)

	return {"multiplier": remap(crit_multiplier_percent, 0, 100, 1, 2), "is_critical": is_critical}


func _get_power_fragility_multiplier(action_type: Utils.ActionType) -> float:
	var power: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_POWER, action_type)
	var fragility: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_FRAGILITY, action_type)
	return (100.0 + power) / (100.0 + fragility)


func _consume_before_action_modifiers(action_type: Utils.ActionCategory, modifiers_dict: Dictionary) -> Dictionary:
	if _owner.action_modifiers_registry != null:
		for modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(action_type):
			if modifier.before_action_logic_callback.is_valid():
				modifier.before_action_logic_callback.call(modifiers_dict)
	return modifiers_dict


func _consume_after_action_modifiers(action_type: Utils.ActionCategory, modifiers_dict: Dictionary) -> Dictionary:
	if _owner.action_modifiers_registry != null:
		for modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(action_type):
			if modifier.after_action_logic_callback.is_valid():
				modifier.after_action_logic_callback.call(modifiers_dict)
	return modifiers_dict


func _is_dodged(action_type: Utils.ActionType, source: Entity) -> bool:
	var dodge_chance: float = _owner.stats.get_effective_stat(EntityStats.StatType.DODGE, action_type)
	_dodge_number += 1
	if Utils.is_randomize_modifier_active(dodge_chance, _owner.battle_id, "dodge_check_" + str(_global_dodge_number)):
		_global_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(Utils.ActionCategory.DODGE):
			if dodge_modifier.after_action_logic_callback.is_valid():
				dodge_modifier.after_action_logic_callback.call({
					ActionModifier.VarType.DODGE_NUMBER: _dodge_number, 
					ActionModifier.VarType.TARGET: source
				})
		return true
	return false


func _get_resistance_exposure_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_RESISTANCE, action_type)
	var exposure: float = _owner.stats.get_effective_stat(EntityStats.StatType.M_EXPOSURE, action_type)
	return (100 + exposure) / (100 + res)


func _get_crit_resistance_multiplier(_action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_RESISTANCE)
	return 100.0 / (100.0 + res)


# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.FIGHTING: _dodge_number = 0
#endregion
