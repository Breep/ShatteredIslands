class_name ActionSenderHealModule
extends ActionSenderModule

# ============================== Public functions ==============================

func heal(target: Entity, heal_amount: float, action_id: StringName) -> Dictionary:
	if not multiplayer.is_server(): return {}
	if target == null: return {}
	
	if _owner.action_modifiers_registry != null:
		var modifiers_dict: Dictionary = {
			ActionModifier.VarType.HEAL_AMOUNT: heal_amount,
			ActionModifier.VarType.TARGET: target
		}
		for modifier: ActionModifier in _owner.action_modifiers_registry.get_all_modifiers(ActionModifier.ActionType.HEAL):
			if modifier.before_action_logic_callback.is_valid():
				modifier.before_action_logic_callback.call(modifiers_dict)
		heal_amount = modifiers_dict[ActionModifier.VarType.HEAL_AMOUNT]
	
	var heal_amount_before_crit: float = heal_amount * _get_strenght_weakness_multiplier(Utils.ActionType.UTILITY_HEAL)
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_HEAL)
	heal_amount = heal_amount_before_crit * crit_multiplier["multiplier"]
	var heal_taken: float = target.take_heal(heal_amount, crit_multiplier["is_critical"], action_id, _owner)
	
	var overheal_amount: float = heal_amount - heal_taken
	
	return {
		ResultKey.VALUE: heal_taken,
		ResultKey.IS_CRITICAL: crit_multiplier["is_critical"],
		ResultKey.BASE_VALUE: heal_amount_before_crit,
		ResultKey.OVERHEAL: overheal_amount,
	}


func heal_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> Dictionary:
	if not multiplayer.is_server(): return {}
	if target == null: return {}
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
