class_name SE_PlumageEpineux
extends SkillEffect

# Passif "Plumage épineux": au spawn, donne _thorn Thorn à un allié aléatoire.

@export var _thorn: float = 1.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var ally: Entity = chicken.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY)
	if is_instance_valid(ally):
		ally.alterations.add_stack(Alteration.Type.THORN, _thorn, chicken, &"Plumage épineux")
