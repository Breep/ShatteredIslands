class_name ActionSenderDamageModule
extends ActionSenderModule

# ============================== Public functions ==============================

func direct_damage(target: Entity, damage: float, damage_type: Utils.DamageType, action_id: StringName) -> Dictionary:
	if not multiplayer.is_server(): return {}
	if target == null: return {}
	
	var damage_before_crit: float = damage * _get_strenght_weakness_multiplier(Utils.damage_to_action(damage_type))
	var crit_multiplier: Dictionary = _get_crit_multiplier(Utils.damage_to_action(damage_type))
	damage = damage_before_crit * crit_multiplier["multiplier"]
	var damage_done: float = target.take_damage(damage, damage_type, crit_multiplier["is_critical"], action_id, _owner)

	return {
		ResultKey.VALUE: damage_done,
		ResultKey.IS_CRITICAL: crit_multiplier["is_critical"],
		ResultKey.BASE_VALUE: damage_before_crit,
	}


func direct_damage_percent(target: Entity, damage_percent: float, damage_type: Utils.DamageType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> Dictionary:
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
	var damage: float = hp * damage_percent / 100.0
	return direct_damage(target, damage, damage_type, action_id)
