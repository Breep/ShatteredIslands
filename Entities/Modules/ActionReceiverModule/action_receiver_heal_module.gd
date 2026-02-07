class_name ActionReceiverHealModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	if multiplayer.is_server():
		if _is_dodged(Utils.ActionType.UTILITY_HEAL):
			return {ResultKey.DODGED: true}
		heal_amount *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_HEAL)
	
	# Necrosis logic
	var necrosis_stacks: float = _owner.conditions.necrosis_stacks
	var absorbed_by_necrosis: float = 0.0
	if necrosis_stacks > 0:
		absorbed_by_necrosis = min(heal_amount, necrosis_stacks)
		_owner.conditions.remove_stack(Stack.Type.NECROSIS, absorbed_by_necrosis)
		heal_amount -= absorbed_by_necrosis

	var initial_health: float = _owner.stats.health
	if heal_amount > 0:
		_owner.stats.health += heal_amount
	
	var effective_heal: float = _owner.stats.health - initial_health
	
	return {
		ResultKey.VALUE: effective_heal,
		ResultKey.IS_CRITICAL: is_critical,
	}
