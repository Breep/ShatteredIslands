class_name ActionSenderModule
extends Module

# ============================== Enums ==============================

enum ResultKey {
	VALUE,           # Final result (damage_done, heal_taken, stacks_applied, etc.)
	IS_CRITICAL,     # Whether the action was critical
	BASE_VALUE,      # Value before crit (for critical_action_done signal)
	OVERHEAL,        # Overheal amount (heal functions only)
}

# ============================== Protected functions ==============================

func _get_crit_multiplier(action_type: Utils.ActionType) -> Dictionary:
	var is_critical: bool = false
	var crit_chance: float = _owner.stats.get_stat(EntityStats.StatType.CRIT_CHANCE, action_type)
	var crit_multiplier_percent: float = 0.0
	
	if Utils.is_randomize_modifier_active(crit_chance):
		is_critical = true
		crit_multiplier_percent = _owner.stats.get_stat(EntityStats.StatType.CRIT_MULT, action_type)
	
	return {"multiplier": remap(crit_multiplier_percent, 0, 100, 1, 2), "is_critical": is_critical}


func _get_strenght_weakness_multiplier(action_type: Utils.ActionType) -> float:
	var strength: float = _owner.stats.get_stat(EntityStats.StatType.STRENGTH, action_type)
	var weakness: float = _owner.stats.get_stat(EntityStats.StatType.WEAKNESS, action_type)
	return (100.0 + strength) / (100.0 + weakness)


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
