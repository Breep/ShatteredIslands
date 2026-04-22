class_name ActionSenderStatusModule
extends ActionSenderModule


func inflict_status(target: Entity, status_type: Alteration.Type, duration: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	var value: float = duration * _get_power_fragility_multiplier(Alteration.to_action(status_type))
	var actual_duration: float = target.take_status(status_type, value, action_id, _owner)
	var action_type: Utils.ActionType = Utils.status_to_action(status_type)
	_owner.action_done.emit(target, action_type, action_id, actual_duration, false)
	return duration
