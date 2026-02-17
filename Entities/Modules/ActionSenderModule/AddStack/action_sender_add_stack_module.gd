class_name ActionSenderAddStackModule
extends ActionSenderModule

# ============================== Public functions ==============================

func inflict_condition_stacks(target: Entity, value: float, stack_type: Utils.StackType, action_id: StringName, duration: float = 5.0) -> float:
	if is_instance_valid(target) == null: return 0
	if not multiplayer.is_server(): return 0
	
	var base_value: float = value * _get_strenght_weakness_multiplier(Utils.stack_to_action(stack_type))
	var crit_data: Dictionary = _get_crit_multiplier(Utils.stack_to_action(stack_type))
	value = base_value * crit_data["multiplier"]
	
	var modifiers_data: Dictionary = _consume_before_action_modifiers(ActionModifier.ActionType.INFLICT_CONDITION, {
		ActionModifier.VarType.STACK_VALUE: value,
		ActionModifier.VarType.STACK_TYPE: stack_type,
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.DURATION: duration
	})
	
	value = modifiers_data[ActionModifier.VarType.STACK_VALUE]
	duration = modifiers_data[ActionModifier.VarType.DURATION]
	
	var stacks_inflicted: float = target.take_condition_stacks(value, stack_type, crit_data["is_critical"], action_id, _owner, duration)
	
	_consume_after_action_modifiers(ActionModifier.ActionType.INFLICT_CONDITION, {
		ActionModifier.VarType.STACK_VALUE: stacks_inflicted,
		ActionModifier.VarType.STACK_TYPE: stack_type,
		ActionModifier.VarType.TARGET: target,
		ActionModifier.VarType.DURATION: duration
	})
	
	_owner.critical_action_done.emit(target, Utils.stack_to_action(stack_type), base_value, stacks_inflicted)
	_owner.action_done.emit(target, Utils.stack_to_action(stack_type), action_id, stacks_inflicted, crit_data["is_critical"])
	return stacks_inflicted
