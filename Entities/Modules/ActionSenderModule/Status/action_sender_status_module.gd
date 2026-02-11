class_name ActionSenderStatusModule
extends ActionSenderModule

## Handles inflicting status effects on targets


func inflict_status(target: Entity, status_type: Status.Type, duration: float, action_id: StringName) -> Dictionary:
	if target == null:
		Verbose.warn("inflict_status: No target", Verbose.Category.ENTITY_MODULE)
		return {
			ActionSenderModule.ResultKey.VALUE: 0.0,
			ActionSenderModule.ResultKey.IS_CRITICAL: false
		}
	
	var actual_duration: float = target.take_status(status_type, duration, action_id, _owner)
	
	# Register in BDS
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.bds_registry.register_action(action_id, action_type, actual_duration, false)
	
	return {
		ActionSenderModule.ResultKey.VALUE: actual_duration,
		ActionSenderModule.ResultKey.IS_CRITICAL: false
	}
