class_name ActionSenderAddStackModule
extends ActionSenderModule

# ============================== Public functions ==============================

func inflict_condition_stacks(target: Entity, stacks_number: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> Dictionary:
	if not multiplayer.is_server(): return {}
	if target == null: return {}
	
	var stacks_number_before_crit: float = stacks_number * _get_strenght_weakness_multiplier(Utils.stack_to_action(stack_type))
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.stack_to_action(stack_type))
	stacks_number = stacks_number_before_crit * crit_multiplier["multiplier"]
	
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.STACK_VALUE: stacks_number,
			ActionModifier.VarType.STACK_TYPE: stack_type,
			ActionModifier.VarType.TARGET: target,
			ActionModifier.VarType.DURATION: duration
		}
		for condition_modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.INFLICT_CONDITION):
			if condition_modifier.before_action_logic_callback.is_valid():
				condition_modifier.before_action_logic_callback.call(modifiers_dict)
		
		stacks_number = modifiers_dict[ActionModifier.VarType.STACK_VALUE]
		duration = modifiers_dict[ActionModifier.VarType.DURATION]
	
	var stacks_taken: float = target.take_condition_stacks(stacks_number, stack_type, crit_multiplier["is_critical"], action_id, _owner, duration)
	
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.STACK_VALUE: stacks_number,
			ActionModifier.VarType.STACK_TYPE: stack_type,
			ActionModifier.VarType.TARGET: target,
			ActionModifier.VarType.DURATION: duration
		}
		for condition_modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.INFLICT_CONDITION):
			if condition_modifier.after_action_logic_callback.is_valid():
				condition_modifier.after_action_logic_callback.call(modifiers_dict)
	
	return {
		ResultKey.VALUE: stacks_taken,
		ResultKey.IS_CRITICAL: crit_multiplier["is_critical"],
		ResultKey.BASE_VALUE: stacks_number_before_crit,
	}
