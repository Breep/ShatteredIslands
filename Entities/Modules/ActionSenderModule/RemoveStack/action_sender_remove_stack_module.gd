class_name ActionSenderRemoveStackModule
extends ActionSenderModule

# ============================== Public functions ==============================

# Removes debuffs (cleanse)
func cleanse(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	if not multiplayer.is_server(): return 0
	
	var base_value: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	value = base_value * crit_data["multiplier"]
	var stack_cleansed: float = target.take_cleanse(value, crit_data["is_critical"], action_id, _owner)
	
	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, base_value, stack_cleansed)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, stack_cleansed, crit_data["is_critical"])
	return stack_cleansed


# Removes buffs (dispell)
func dispell(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	if not multiplayer.is_server(): return 0
	
	var base_value: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_DISPELL)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_DISPELL)
	value = base_value * crit_data["multiplier"]
	var stack_removed: float = target.take_dispell(value, crit_data["is_critical"], action_id, _owner)
	
	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, base_value, stack_removed)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_CLEANSE, action_id, stack_removed, crit_data["is_critical"])
	return stack_removed
