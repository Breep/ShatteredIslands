class_name SE_InstinctDeMeute
extends SkillEffect

# Passif "Instinct de meute": au spawn, le poulet gagne _block Block.

@export var _block: float = 2.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.direct_stack(chicken, _block, Alteration.Type.BLOCK, &"Instinct de meute")


func get_description() -> String:
	return "À son apparition, gagne " + _value(_block) + " [[BLOCK]]."
