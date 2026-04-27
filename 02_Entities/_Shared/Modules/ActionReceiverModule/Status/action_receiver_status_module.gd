class_name ActionReceiverStatusModule
extends ActionReceiverModule

func take_status(status_type: Alteration.Type, duration: float, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if _owner.alterations_module.has_state(Alteration.Type.INVULNERABLE) and Alteration.is_negative(status_type): return 0

	if _owner.alterations_module == null:
		Verbose.error("take_status: No AlterationsModule on owner", Verbose.Category.ENTITY_MODULE)
		return 0

	_owner.alterations_module.apply_status(status_type, duration)

	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.action_received.emit(source, action_type, action_id, duration, false)
	return duration
