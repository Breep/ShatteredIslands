class_name HealModule
extends ActionSenderModule

# Component-based heal module: handles both outgoing (direct/direct_percent)
# and incoming (take) heal. Fused from former
# ActionSenderHealModule + ActionReceiverHealModule.

# ============================== Public functions ==============================

func direct(target: Entity, value: float, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0

	var modifiers_data: Dictionary = _consume_before_action_modifiers(Utils.ActionCategory.HEAL, {
		ActionModifier.VarType.HEAL_AMOUNT: value,
		ActionModifier.VarType.TARGET: target
	})
	value = modifiers_data[ActionModifier.VarType.HEAL_AMOUNT]

	var base_value: float = value * _get_power_fragility_multiplier(Utils.ActionType.UTILITY_HEAL)
	var crit_data: Dictionary = _get_crit_multiplier(Utils.ActionType.UTILITY_HEAL)
	value = base_value * crit_data["multiplier"]
	var heal_done: float = target.heal.take(value, crit_data["is_critical"], action_id, _owner)
	var overheal_amount: float = value - heal_done

	if overheal_amount > 0:
		_owner.action_overhealed.emit(target, overheal_amount)
	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, Utils.ActionType.UTILITY_HEAL, base_value, value)
	_owner.action_done.emit(target, Utils.ActionType.UTILITY_HEAL, action_id, value, crit_data["is_critical"])
	return heal_done


func direct_percent(target: Entity, percent: float, percent_modifier: Utils.PercentModifier, action_id: StringName) -> float:
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var heal_amount: float = (percent * hp as float) / 100.0
	return direct(target, heal_amount, action_id)


func take(heal_amount: float, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if multiplayer.is_server():
		heal_amount *= _get_resistance_exposure_multiplier(Utils.ActionType.UTILITY_HEAL)
		if _is_dodged(Utils.ActionType.UTILITY_HEAL, source):
			_owner.action_dodged.emit(source, Utils.ActionType.UTILITY_HEAL, heal_amount, is_critical)
			return 0
	var initial_health: float = _owner.stats.health
	if heal_amount > 0:
		_owner.stats.health += heal_amount
	var effective_heal: float = _owner.stats.health - initial_health
	_owner.heal_taken.emit(effective_heal, is_critical)
	_owner.action_received.emit(source, Utils.ActionType.UTILITY_HEAL, action_id, effective_heal, is_critical)
	return effective_heal


# ============================== Receiver helpers (inlined from former ActionReceiverModule) ==============================

static var _global_dodge_number: int = 0
var _dodge_number: int = -1


func _is_dodged(action_type: Utils.ActionType, source: Entity) -> bool:
	var dodge_chance: float = _owner.stats.get_stat(EntityStats.StatType.DODGE, action_type)
	_dodge_number += 1
	if Utils.is_randomize_modifier_active(dodge_chance, _owner.battle_id, "dodge_check_" + str(_global_dodge_number)):
		_global_dodge_number += 1
		for dodge_modifier: ActionModifier in _owner.action_modifiers_registry.consume_all_modifiers(Utils.ActionCategory.DODGE):
			if dodge_modifier.after_action_logic_callback.is_valid():
				dodge_modifier.after_action_logic_callback.call({
					ActionModifier.VarType.DODGE_NUMBER: _dodge_number,
					ActionModifier.VarType.TARGET: source
				})
		return true
	return false


func _get_resistance_exposure_multiplier(action_type: Utils.ActionType) -> float:
	var res: float = _owner.stats.get_stat(EntityStats.StatType.RESISTANCE, action_type)
	var exposure: float = _owner.stats.get_stat(EntityStats.StatType.EXPOSURE, action_type)
	return (100 + exposure) / (100 + res)
