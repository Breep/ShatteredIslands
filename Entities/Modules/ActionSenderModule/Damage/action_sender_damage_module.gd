class_name ActionSenderDamageModule
extends ActionSenderModule

# ============================== Public functions ==============================

func direct_damage(target: Entity, damage: float, damage_type: Utils.ActionType, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0
	
	var base_damage: float = damage * _get_strenght_weakness_multiplier(damage_type)
	var crit_data: Dictionary = _get_crit_multiplier(damage_type)
	damage = base_damage * crit_data["multiplier"]
	var damage_done: float = target.take_damage(damage, damage_type, crit_data["is_critical"], action_id, _owner)
	_handle_life_steal(damage_done, damage_type)
	
	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, damage_type, base_damage, damage_done)
	_owner.action_done.emit(target, damage_type, action_id, damage_done, crit_data["is_critical"])
	return damage_done


func direct_damage_percent(target: Entity, damage_percent: float, damage_type: Utils.ActionType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> float:
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var damage: float = hp * damage_percent / 100.0
	return direct_damage(target, damage, damage_type, action_id)


func _handle_life_steal(damage_done: float, damage_type: Utils.ActionType) -> void:
	var life_steal: float = _owner.stats.get_stat(EntityStats.StatType.LIFESTEAL, damage_type)
	var heal: float = damage_done * life_steal / 100.0
	if heal >= 1:
		_owner.heal(_owner, heal, &"Life Steal")
