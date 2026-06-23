class_name SE_ProtectorWarcry
extends SkillEffect

func apply(ctx: SkillContext) -> void:
	var _owner: Entity = ctx.entity
	if _owner != null and is_instance_valid(_owner):
		var allies: Array[Entity] = _owner.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES)
		var shield_gain: float = (_owner.stats.armor * 10)
		for entity in allies:
			_owner.alterations.direct_stack(entity, shield_gain, Alteration.Type.SHIELD, &"Goblin Protection")


func get_description() -> String:
	return "Accorde à tous les alliés un [[SHIELD]] égal à " + _value(10) + "× son [[ARMOR]]."
	
