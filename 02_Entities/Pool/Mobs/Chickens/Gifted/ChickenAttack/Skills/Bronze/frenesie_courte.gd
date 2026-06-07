class_name SE_FrenesieCourte
extends SkillEffect

# Talent "Frénésie courte": +_ad_bonus AD.

@export var _ad_bonus: float = 20.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var modifier := StatModifier.new()
	modifier.id = &"FrenesieCourte"
	modifier.stat_type = EntityStats.StatType.AD
	modifier.value = _ad_bonus
	chicken.stat_modifiers_registry.register_modifier(modifier)
