class_name SE_HawkEye
extends SkillEffect

# Talent Bronze "Œil du Faucon" : +_range_bonus m de portée, et les ennemis à plus de
# _distance_threshold m subissent +_far_damage_percent % de dégâts d'auto-attaque de
# Latika. Scaling distance / prédation à longue portée.

@export var _range_bonus: float = 3.0
@export var _distance_threshold: float = 6.0
@export var _far_damage_percent: float = 30.0


func apply(ctx: SkillContext) -> void:
	var latika: Entity = ctx.entity
	if latika == null:
		Verbose.error("SE_HawkEye: null owner", Verbose.Category.ENTITY_MODULE)
		return

	var range_mod := StatModifier.new()
	range_mod.id = &"HawkEyeRange"
	range_mod.stat_type = EntityStats.StatType.AR
	range_mod.value = _range_bonus
	latika.stat_modifiers_registry.register_modifier(range_mod)

	var modifier := AutoAttackModifier.new()
	modifier.id = &"HawkEyeFarDamage"
	modifier.is_one_time_effect = false
	modifier.damage_modifier_callback = func(data: Dictionary) -> void:
		var source: Entity = data.get(AutoAttackModifier.VarType.SOURCE)
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(source) or not is_instance_valid(target):
			return
		if source.global_position.distance_to(target.global_position) > _distance_threshold:
			data[AutoAttackModifier.VarType.DAMAGE_MUL] += _far_damage_percent
	latika.auto_attack_modifier_registry.register_modifier(modifier)
