class_name ActionReceiverModule
extends Module

# ============================== Enums ==============================

enum ResultKey {
	VALUE, # Damage/heal/stacks received
	IS_CRITICAL, # Whether the action was critical
	BLOCKED_BY_ARMOR, # Whether damage was reduced by armor
	DODGED, # Whether the action was dodged
	INVULNERABLE, # Whether the action was blocked by invulnerability
}

# ============================== Private variables ==============================

var _dodge_number: int = 0

# ============================== Protected functions ==============================

func _is_dodged(action_type: Utils.ActionType) -> bool:
	var dodge_chance: float = _owner.stats.get_stat(EntityStats.StatType.DODGE, action_type)
	if Utils.is_randomize_modifier_active(dodge_chance):
		_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(Utils.ActionCategory.DODGE):
			if dodge_modifier.after_action_logic_callback.is_valid():
				dodge_modifier.after_action_logic_callback.call({
					ActionModifier.VarType.DODGE_NUMBER: _dodge_number
				})
		return true
	return false


func _get_resistance_vulnerability_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.RESISTANCE, action_type)
	var vuln: float = _owner.stats.get_stat(EntityStats.StatType.VULNERABILITY, action_type)
	return (100 + vuln) / (100 + res)


func _get_crit_resistance_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_RESISTANCE, action_type)
	return 100.0 / (100.0 + res)


# ============================== Callbacks ==============================

func _on_game_manager_game_state_changed(game_state: GameManager.GameState) -> void:
	match game_state:
		GameManager.GameState.FIGHTING: _dodge_number = 0
