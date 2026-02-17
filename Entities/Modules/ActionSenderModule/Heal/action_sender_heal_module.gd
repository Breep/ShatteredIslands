class_name ActionSenderHealModule
extends ActionSenderModule

# ============================== Public functions ==============================

func heal(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	if not multiplayer.is_server(): return 0
	
	var modifiers_data: Dictionary = _consume_before_action_modifiers(ActionModifier.ActionType.HEAL, {
		ActionModifier.VarType.HEAL_AMOUNT: value,
		ActionModifier.VarType.TARGET: target
	})
	value = modifiers_data[ActionModifier.VarType.HEAL_AMOUNT]
	
	var base_value: float = value * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_HEAL)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_HEAL)
	value = base_value * crit_data["multiplier"]
	var heal_done: float = target.take_heal(value, crit_data["is_critical"], action_id, _owner)
	var overheal_amount: float = value - heal_done
	
	if overheal_amount > 0:
		_owner.action_overhealed.emit(target, overheal_amount)
	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, base_value, value)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, value, crit_data["is_critical"])
	return heal_done


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> float:
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var heal_amount: float = (percent * hp as float) / 100.0
	return heal(target, heal_amount, action_id)
