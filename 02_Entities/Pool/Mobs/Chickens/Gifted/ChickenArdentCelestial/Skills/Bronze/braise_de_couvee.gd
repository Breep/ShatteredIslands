class_name SE_BraiseDeCouvee
extends SkillEffect

# Talent "Braise de couvée": chaque attaque applique AP x _ap_ignite_ratio Ignite à la cible.

@export var _ap_ignite_ratio: float = 0.25


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"BraiseDeCouvee"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(data: Dictionary) -> void:
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target):
			return
		var ignite: float = chicken.stats.get_stat(EntityStats.StatType.AP) * _ap_ignite_ratio
		chicken.alterations.direct_stack(target, ignite, Alteration.Type.IGNITE, &"Braise de couvée")
	chicken.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "À chaque attaque, applique [[IGNITE]] égal à " + _value(_ap_ignite_ratio) \
		+ "× son [[AP]] à la cible."
