class_name ActionReceiverDamageModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_damage(damage: float, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if _owner.is_invulnerable(): return 0
	if damage_type != Utils.DamageType.PURE and multiplayer.is_server():
		if _is_dodged(Utils.damage_to_action(damage_type), source):
			_owner.action_dodged.emit(source, Utils.damage_to_action(damage_type))
			return 0
		if _is_blocked(): return 0
		_handle_thorn(source, action_id)
		damage *= _get_resistance_vulnerability_multiplier(Utils.damage_to_action(damage_type))
		if is_critical:
			damage *= _get_crit_resistance_multiplier(Utils.damage_to_action(damage_type))
		damage = _owner.conditions.get_shield_reduced_damage(damage, damage_type)
	_owner.stats.health -= damage
	_owner.damage_taken.emit(damage, damage_type, is_critical, false)
	_owner.interaction_received.emit(source, Utils.damage_to_action(damage_type), action_id, damage, is_critical)
	return damage


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.DamageType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
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


func _is_blocked() -> bool:
	if _owner.stats.block >= 1:
		_owner.stats.block -= 1
		return true
	return false


func _handle_thorn(source: Entity, action_id: StringName) -> void:
	if action_id != &"auto_attack": return
	if _owner.stats.thorn >= 1 and is_instance_valid(source):
		_owner.direct_damage(source, _owner.stats.thorn, Utils.DamageType.PHYSICAL, action_id)
