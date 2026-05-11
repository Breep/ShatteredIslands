class_name DamageComponent
extends EntityComponent

# Component-based damage module: handles both outgoing (direct/direct_percent)
# and incoming (take/take_percent) damage.

# ============================== Public functions ==============================

func direct(target: Entity, damage: float, damage_type: Utils.ActionType, action_id: StringName) -> float:
	if not is_instance_valid(target): return 0

	var base_damage: float = damage * _get_power_fragility_multiplier(damage_type)
	var crit_data: Dictionary = _get_crit_multiplier(damage_type)
	damage = base_damage * crit_data["multiplier"]
	var damage_done: float = target.damage.take(damage, damage_type, crit_data["is_critical"], action_id, _owner)
	_handle_life_steal(damage_done, damage_type)

	if crit_data["is_critical"]:
		_owner.critical_action_done.emit(target, damage_type, base_damage, damage_done)
	_owner.action_done.emit(target, damage_type, action_id, damage_done, crit_data["is_critical"])
	return damage_done


func direct_percent(target: Entity, damage_percent: float, damage_type: Utils.ActionType, percent_modifier: Utils.PercentModifier, action_id: StringName) -> float:
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = target.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = target.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = target.stats.health_max - target.stats.health
	var damage: float = hp * damage_percent / 100.0
	return direct(target, damage, damage_type, action_id)


func take(damage: float, damage_type: Utils.ActionType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	if _owner.is_dead(): return 0
	if _owner.alterations != null and _owner.alterations.has_state(Alteration.Type.INVULNERABLE): return 0
	if damage_type != Utils.ActionType.DAMAGE_PURE and multiplayer.is_server():
		damage *= _get_resistance_exposure_multiplier(damage_type)
		if is_critical:
			damage *= _get_crit_resistance_multiplier(damage_type)
		damage = _owner.alterations.get_shield_reduced_damage(damage, damage_type)
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


func take_percent(damage_percent: float, percent_modifier: Utils.PercentModifier, damage_type: Utils.ActionType, is_critical: bool, action_id: StringName, source: Entity = null) -> float:
	var hp: float
	match percent_modifier:
		Utils.PercentModifier.MAX_HP:
			hp = _owner.stats.health_max
		Utils.PercentModifier.CURRENT_HP:
			hp = _owner.stats.health
		Utils.PercentModifier.LOST_HP:
			hp = _owner.stats.health_max - _owner.stats.health
	var damage: float = hp * damage_percent / 100.0
	return take(damage, damage_type, is_critical, action_id, source)


# ============================== Private functions ==============================

func _handle_life_steal(damage_done: float, damage_type: Utils.ActionType) -> void:
	var life_steal: float = _owner.stats.get_effective_stat(EntityStats.StatType.LIFESTEAL, damage_type)
	var amount: float = damage_done * life_steal / 100.0
	if amount >= 1:
		_owner.heal.direct(_owner, amount, &"Life Steal")


func _is_blocked(damage_type: Utils.ActionType) -> bool:
	if _owner.alterations == null: return false
	return _owner.alterations.block_alteration.try_consume(damage_type)


func _handle_thorn(source: Entity, action_id: StringName) -> void:
	if action_id != &"auto_attack": return
	if _owner.alterations == null: return
	var thorn: float = _owner.alterations.thorn_alteration.get_return_damage()
	if thorn >= 1 and is_instance_valid(source):
		direct(source, thorn, Utils.ActionType.DAMAGE_PHYSICAL, &"Thorn")
