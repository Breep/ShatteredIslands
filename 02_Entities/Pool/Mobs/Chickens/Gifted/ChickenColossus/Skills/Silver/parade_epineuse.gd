class_name SE_ParadeEpineuse
extends SkillEffect

# Talent "Parade épineuse": au spawn, le poulet gagne _thorn Thorn supplémentaires.

@export var _thorn: float = 25.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.direct_stack(chicken, _thorn, Alteration.Type.THORN, &"Parade épineuse")


func get_description() -> String:
	return "À son apparition, gagne " + _value(_thorn) + " [[THORN]]."
