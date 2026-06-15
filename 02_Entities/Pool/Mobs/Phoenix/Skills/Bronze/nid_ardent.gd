class_name SE_NidArdent
extends SkillEffect

# Talent "Nid ardent": les attaques automatiques appliquent AP x _ap_ratio Ignite à la cible.

@export var _ap_ratio: float = 1.0


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	var modifier := AutoAttackModifier.new()
	modifier.id = &"NidArdent"
	modifier.is_one_time_effect = false
	modifier.additional_effect_callback = func(_data: Dictionary) -> void:
		var target: Entity = phoenix.auto_attack.get_current_target() if phoenix.auto_attack != null else null
		if not is_instance_valid(target):
			return
		var ignite: float = phoenix.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
		phoenix.alterations.inflict_condition_stacks(target, ignite, Alteration.Type.IGNITE, &"Nid ardent")
	phoenix.auto_attack_modifier_registry.register_modifier(modifier)


func get_description() -> String:
	return "Chaque auto-attaque applique des stacks d'[[IGNITE]] égaux à " \
		+ _value(_ap_ratio * 100) + "% de sa puissance magique à la cible."
