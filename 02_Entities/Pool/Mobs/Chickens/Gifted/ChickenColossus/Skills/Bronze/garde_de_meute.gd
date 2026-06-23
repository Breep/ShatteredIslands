class_name SE_GardeDeMeute
extends SkillEffect

# Talent "Garde de meute": au spawn, le poulet s'applique Taunt (état permanent, sans durée :
# TAUNT est un StateAlteration on/off) pour forcer les ennemis à le cibler.


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	chicken.alterations.direct_status(chicken, Alteration.Type.TAUNT, 0.0, &"Garde de meute")


func get_description() -> String:
	return "À son apparition, gagne [[TAUNT]] pour forcer les ennemis à le cibler."
