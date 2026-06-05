class_name SE_EntailleProtectrice
extends SkillEffect

# Talent "Entaille protectrice": toutes les _combo_period attaques, la suivante inflige
# AD x (100 + _damage_mult_bonus)% dégâts physiques et convertit _convert_ratio des dégâts
# en Shield donné à l'allié ayant le moins de Shield.

@export var _combo_period: int = 4
@export var _damage_mult_bonus: float = 50.0  # +50 → AD x 150%
@export var _convert_ratio: float = 0.5


func apply(ctx: SkillContext) -> void:
	var blade: AegisBlade = ctx.entity as AegisBlade
	if blade == null:
		Verbose.error("SE_EntailleProtectrice: owner is not an AegisBlade", Verbose.Category.ENTITY_MODULE)
		return

	var count: Array[int] = [0]
	blade.auto_attack_completed.connect(func(_attacker: Entity) -> void:
		count[0] += 1
		if count[0] == _combo_period - 1:
			_arm_combo(blade)
		elif count[0] >= _combo_period:
			count[0] = 0
	)


func _arm_combo(blade: AegisBlade) -> void:
	var modifier := AutoAttackModifier.new()
	modifier.id = &"EntailleProtectrice"
	modifier.is_one_time_effect = true
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		data[AutoAttackModifier.VarType.DAMAGE_MUL] += _damage_mult_bonus
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var damage: float = data.get(AutoAttackModifier.VarType.DAMAGE, 0.0)
		if damage <= 0.0:
			return
		var ally: Entity = _lowest_shield_ally(blade)
		if is_instance_valid(ally):
			blade.alterations.inflict_condition_stacks(ally, damage * _convert_ratio, Alteration.Type.SHIELD, &"Entaille protectrice")
	blade.auto_attack_modifier_registry.register_modifier(modifier)


func _lowest_shield_ally(blade: AegisBlade) -> Entity:
	var best: Entity = null
	for ally: Entity in blade.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES):
		if not is_instance_valid(ally):
			continue
		if best == null or ally.alterations.shield_stacks < best.alterations.shield_stacks:
			best = ally
	return best
