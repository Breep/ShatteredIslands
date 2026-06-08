class_name SE_ChickenRun
extends SkillEffect

# Ultimate "Chicken Run": invoque une horde de _count poulets d'un coup, avec les règles
# du poulailler (niveau hérité, gifted périodique, block).

@export var _count: int = 5


func apply(ctx: SkillContext) -> void:
	var coop: ChickenCoop = ctx.entity as ChickenCoop
	if coop == null:
		Verbose.error("SE_ChickenRun: owner is not a ChickenCoop", Verbose.Category.ENTITY_MODULE)
		return
	for i: int in _count:
		coop.summon_chicken()
