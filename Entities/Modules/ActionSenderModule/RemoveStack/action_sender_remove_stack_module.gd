class_name ActionSenderRemoveStackModule
extends ActionSenderModule

# ============================== Public functions ==============================

# Removes debuffs (cleanse)
func cleanse(target: Entity, value: float, action_id: StringName) -> Dictionary:
	if target == null or target.is_queued_for_deletion(): return {}
	var value_before_crit: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_CLEANSE)
	value = value_before_crit * crit_multiplier["multiplier"]
	var stack_removed: float = target.take_cleanse(value, crit_multiplier["is_critical"], action_id, _owner)
	
	return {
		ResultKey.VALUE: stack_removed,
		ResultKey.IS_CRITICAL: crit_multiplier["is_critical"],
		ResultKey.BASE_VALUE: value_before_crit,
	}


# Removes buffs (dispell)
func dispell(target: Entity, value: float, action_id: StringName) -> Dictionary:
	if target == null or target.is_queued_for_deletion(): return {}
	var value_before_crit: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_DISPELL)
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_DISPELL)
	value = value_before_crit * crit_multiplier["multiplier"]
	var stack_removed: float = target.take_dispell(value, crit_multiplier["is_critical"], action_id, _owner)
	
	return {
		ResultKey.VALUE: stack_removed,
		ResultKey.IS_CRITICAL: crit_multiplier["is_critical"],
		ResultKey.BASE_VALUE: value_before_crit,
	}
