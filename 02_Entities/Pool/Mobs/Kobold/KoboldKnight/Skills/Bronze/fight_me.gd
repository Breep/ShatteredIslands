class_name SE_FightMe
extends SkillEffect


func apply(ctx: SkillContext) -> void:
	var _owner = ctx.entity
	_owner.alterations.inflict_status(_owner, Alteration.Type.TAUNT, -1, &"FightMe")
