class_name ActionReceiverDamageModule
extends ActionReceiverModule

# ============================== Public functions ==============================

func take_damage(damage: float, damage_type: Utils.ActionType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if _owner.is_invulnerable(): return 0
	if damage_type != Utils.ActionType.DAMAGE_PURE and multiplayer.is_server():
		damage *= _get_resistance_exposure_multiplier(damage_type)
		if is_critical:
			damage *= _get_crit_resistance_multiplier(damage_type)
		damage = _owner.alterations_module.get_shield_reduced_damage(damage, damage_type)
		if _is_dodged(damage_type, source):
			_owner.action_dodged.emit(source, damage_type, damage, is_critical)
			return 0
		_handle_thorn(source, action_id)
		if _is_blocked(damage_type):
			_owner.action_blocked.emit(source, damage_type, damage)
			return 0
	_owner.stats.health -= damage
	_owner.damage_taken.emit(damage, damage_type, is_critical, false)
	_owner.action_received.emit(source, damage_type, action_id, damage, is_critical)
	return damage


func take_damage_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.ActionType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
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


func _is_blocked(damage_type: Utils.ActionType) -> bool:
	if _owner.alterations_module == null: return false
	return _owner.alterations_module.block_alteration.try_consume(damage_type)


func _handle_thorn(source: Entity, action_id: StringName) -> void:
	if action_id != &"auto_attack": return
	if _owner.alterations_module == null: return
	var thorn: float = _owner.alterations_module.thorn_alteration.get_return_damage()
	if thorn >= 1 and is_instance_valid(source):
		_owner.direct_damage(source, thorn, Utils.ActionType.DAMAGE_PHYSICAL, &"Thorn")
