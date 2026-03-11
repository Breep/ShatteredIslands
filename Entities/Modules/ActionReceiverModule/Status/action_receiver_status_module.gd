class_name ActionReceiverStatusModule
extends ActionReceiverModule

func take_status(status_type: Status.Type, duration: float, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if _owner.is_invulnerable() and Status.is_negative_status(status_type): return 0
	
	if _owner.status_module == null:
		Verbose.error("take_status: No StatusModule on owner", Verbose.Category.ENTITY_MODULE)
		return 0
	
	_owner.status_module.add_status(status_type, duration)
	
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.action_received.emit(source, action_type, action_id, duration, false)
	return duration
