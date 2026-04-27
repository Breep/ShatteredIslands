class_name ActionReceiverAddStackModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_condition_stacks(stacks_number: float, stack_type: Alteration.Type, is_critical: bool, action_id: StringName, source: Entity = null, duration: float = 5.0) -> float:
	if _owner.is_dead(): return 0
	if _owner.alterations_module.has_state(Alteration.Type.INVULNERABLE) and Alteration.is_negative(stack_type): return 0
	if multiplayer.is_server():
		stacks_number *= _get_resistance_exposure_multiplier(Alteration.to_action(stack_type))
		if _is_dodged(Alteration.to_action(stack_type), source):
			_owner.action_dodged.emit(source, Alteration.to_action(stack_type), stacks_number, is_critical)
			return 0

	var mod: Dictionary = {}
	if stack_type == Alteration.Type.REGEN:
		mod[Alteration.ModifierType.DURATION] = int(duration)

	_owner.alterations_module.add_stack(stack_type, stacks_number, source, action_id, mod)
	_owner.stack_taken.emit(stack_type, stacks_number, is_critical)
	_owner.action_received.emit(source, Alteration.to_action(stack_type), action_id, stacks_number, is_critical)
	Verbose.trace("Stack received [" + str(stacks_number) + "]", Verbose.Category.ACTION_RECEIVER_MODULE)
	return stacks_number
