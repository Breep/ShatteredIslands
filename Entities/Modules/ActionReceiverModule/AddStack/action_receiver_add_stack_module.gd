class_name ActionReceiverAddStackModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	if multiplayer.is_server():
		if _is_dodged(Utils.stack_to_action(stack_type)):
			return {ResultKey.DODGED: true}
		stacks_number *= _get_resistance_vulnerability_multiplier(Utils.stack_to_action(stack_type))
	
	var stack_enum: Stack.Type = _utils_stack_to_stack_type(stack_type)
	var mod: Dictionary = {}
	if stack_type == Utils.StackType.REGEN:
		mod[Stack.ModifierType.DURATION] = int(duration)
	_owner.conditions.add_stack(stack_enum, stacks_number, source, action_id, mod)
	
	return {
		ResultKey.VALUE: stacks_number,
		ResultKey.IS_CRITICAL: is_critical,
	}
