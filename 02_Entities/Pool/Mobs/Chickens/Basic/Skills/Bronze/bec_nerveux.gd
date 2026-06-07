class_name SE_BecNerveux
extends SkillEffect

# Talent "Bec nerveux": au spawn, donne _block Block à un allié aléatoire.

@export var _block: float = 1.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY)
	if is_instance_valid(ally):
		ally.alterations.add_stack(Alteration.Type.BLOCK, _block, chicken, &"Bec nerveux")
