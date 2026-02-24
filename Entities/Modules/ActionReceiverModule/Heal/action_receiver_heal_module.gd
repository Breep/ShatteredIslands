class_name ActionReceiverHealModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_heal(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if multiplayer.is_server():
		if _is_dodged(Utils.ActionType.UTILITY_HEAL, source):
			_owner.action_dodged.emit(source, Utils.ActionType.UTILITY_HEAL)
			return 0
		heal_amount *= _get_resistance_vulnerability_multiplier(Utils.ActionType.UTILITY_HEAL)
	var initial_health: float = _owner.stats.health
	if heal_amount > 0:
		_owner.stats.health += heal_amount
	var effective_heal: float = _owner.stats.health - initial_health
	_owner.heal_taken.emit(effective_heal, is_critical)
	_owner.interaction_received.emit(source, Utils.ActionType.UTILITY_HEAL, action_id, effective_heal, is_critical)
	return effective_heal
