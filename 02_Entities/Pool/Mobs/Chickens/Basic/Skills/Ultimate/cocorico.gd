class_name SE_Cocorico
extends SkillEffect

# Ultimate "Cocorico": le poulet gagne _block Block.

@export var _block: float = 4.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.add_stack(Alteration.Type.BLOCK, _block, chicken, &"Cocorico")


func get_description() -> String:
	return "Gagne " + _value(_block) + " [[BLOCK]]."
