class_name SE_Cocorico
extends SkillEffect

# Ultimate "Cocorico": le poulet gagne _block Block.

@export var _block: float = 4.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.direct_stack(chicken, _block, Alteration.Type.BLOCK, &"Cocorico")


func get_description() -> String:
	return "Gagne " + _value(_block) + " [[BLOCK]]."
