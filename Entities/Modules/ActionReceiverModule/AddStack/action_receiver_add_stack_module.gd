class_name ActionReceiverAddStackModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_condition_stacks(stacks_number: float, stack_type: Utils.StackType, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	if _owner.is_dead(): return 0
	if _owner.is_invulnerable() and Utils.is_negative_stack(stack_type): return 0
	if multiplayer.is_server():
		if _is_dodged(Utils.stack_to_action(stack_type), source):
			_owner.action_dodged.emit(source, Utils.stack_to_action(stack_type))
			return 0
		stacks_number *= _get_resistance_vulnerability_multiplier(Utils.stack_to_action(stack_type))
	
	var stack_enum: Stack.Type = _utils_stack_to_stack_type(stack_type)
	var mod: Dictionary = {}
	if stack_type == Utils.StackType.REGEN:
		mod[Stack.ModifierType.DURATION] = int(duration)
	
	_owner.conditions.add_stack(stack_enum, stacks_number, source, action_id, mod)
	_owner.stack_taken.emit(stack_type, stacks_number, is_critical)
	_owner.interaction_received.emit(source, Utils.stack_to_action(stack_type), action_id, stacks_number, is_critical)
	return stacks_number
