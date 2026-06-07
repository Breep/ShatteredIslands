class_name SE_RenaissanceSolaire
extends SkillEffect

# Talent "Renaissance solaire" (Phoenix): gagne +_ap_bonus AP jusqu'à la fin du combat.

@export var _ap_bonus: float = 30.0


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	var modifier := StatModifier.new()
	modifier.id = &"RenaissanceSolaire"
	modifier.stat_type = EntityStats.StatType.AP
	modifier.value = _ap_bonus
	phoenix.stat_modifiers_registry.register_modifier(modifier)
