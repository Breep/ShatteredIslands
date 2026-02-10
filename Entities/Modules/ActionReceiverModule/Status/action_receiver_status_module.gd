class_name ActionReceiverStatusModule
extends ActionReceiverModule

## Handles receiving status effects from other entities


func take_status(status_type: Status.Type, duration: float, action_id: StringName, source: Entity) -> Dictionary:
	if _owner.status_module == null:
		Verbose.error("take_status: No StatusModule on owner", Verbose.Category.ENTITY_MODULE)
		return {
			ActionReceiverModule.ResultKey.VALUE: 0.0,
			ActionReceiverModule.ResultKey.IS_CRITICAL: false
		}
	
	if Status.is_negative_status(status_type) and _owner.status_module.has_status(Status.Type.INVULNERABLE):
		return {
			ActionReceiverModule.ResultKey.VALUE: 0.0,
			ActionReceiverModule.ResultKey.IS_CRITICAL: false,
			ActionReceiverModule.ResultKey.INVULNERABLE: true
		}
	
	# Apply the status
	_owner.status_module.add_status(status_type, duration)
	
	# Register in BDS
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.bds_registry.register_interaction(action_id, action_type, duration, false)
	
	return {
		ActionReceiverModule.ResultKey.VALUE: duration,
		ActionReceiverModule.ResultKey.IS_CRITICAL: false
	}
