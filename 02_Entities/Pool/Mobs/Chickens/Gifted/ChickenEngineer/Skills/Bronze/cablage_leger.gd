class_name SE_CablageLeger
extends SkillEffect

# Talent "Câblage léger": au spawn, donne _shield Shield à l'allié le plus blessé.

@export var _shield: float = 20.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_PERCENT_ALLY_INCLUDING_SELF)
	if is_instance_valid(ally):
		chicken.alterations.inflict_condition_stacks(ally, _shield, Alteration.Type.SHIELD, &"Câblage léger")
