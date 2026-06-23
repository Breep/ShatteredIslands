class_name SE_CocotteRempart
extends SkillEffect

# Ultimate "Cocotte rempart": le poulet gagne _thorn Thorn.

@export var _thorn: float = 25.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.direct_stack(chicken, _thorn, Alteration.Type.THORN, &"Cocotte rempart")


func get_description() -> String:
	return "Gagne " + _value(_thorn) + " [[THORN]]."
