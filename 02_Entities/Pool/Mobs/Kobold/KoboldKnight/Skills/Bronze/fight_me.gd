class_name SE_FightMe
extends SkillEffect


func apply(ctx: SkillContext) -> void:
	var _owner = ctx.entity
	_owner.alterations.direct_status(_owner, Alteration.Type.TAUNT, -1, &"FightMe")


func get_description() -> String:
	return "Provoque tous les ennemis pour toute la durée du combat : ils sont " \
		+ "forcés de l'attaquer en priorité."
