class_name ActionReceiverDamageModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if _owner.stats.health <= 0 or _owner.is_dead(): return {}
	
	if _owner.status_module.has_status(Status.Type.INVULNERABLE):
		return {
			ResultKey.VALUE: 0.0,
			ResultKey.IS_CRITICAL: false,
			ResultKey.INVULNERABLE: true
		}

	var damage_before_armor: float = 0
	if damage_type != Utils.DamageType.PURE and multiplayer.is_server():
		if _is_dodged(Utils.damage_to_action(damage_type)):
			return {ResultKey.DODGED: true}
		damage *= _get_resistance_vulnerability_multiplier(Utils.damage_to_action(damage_type))
		
		if is_critical:
			damage *= _get_crit_resistance_multiplier(Utils.damage_to_action(damage_type))
		
		damage_before_armor = damage
		damage = _owner.conditions.get_shield_reduced_damage(damage, damage_type)


	_owner.stats.health -= damage
	
	return {
		ResultKey.VALUE: damage,
		ResultKey.IS_CRITICAL: is_critical,
		ResultKey.BLOCKED_BY_ARMOR: damage_before_armor > damage,
	}


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> Dictionary:
	if not multiplayer.is_server():
		Verbose.warn("take_damage_percent() should not be called by clients", Verbose.Category.ENTITY_MODULE)
		return {}
	
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = _owner.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = _owner.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = _owner.stats.health_max - _owner.stats.health
	var damage: float = hp * damage_percent / 100.0
	return take_damage(damage, damage_type, is_critical, action_id, source)
