class_name SE_ParadeEpineuse
extends SkillEffect

# Talent "Parade épineuse": au spawn, le poulet gagne _thorn Thorn supplémentaires.

@export var _thorn: float = 25.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.add_stack(Alteration.Type.THORN, _thorn, chicken, &"Parade épineuse")
