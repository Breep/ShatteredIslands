class_name SE_BastionAegis
extends SkillEffect

# Ultimate "Bastion Aegis": la Tour donne AP x _ap_ratio Shield à tous les alliés (et
# bâtiments alliés) dans un rayon _radius.

@export var _radius: float = 10.0
@export var _ap_ratio: float = 1.5


func apply(ctx: SkillContext) -> void:
	var tower: AegisTower = ctx.entity as AegisTower
	if tower == null:
		Verbose.error("SE_BastionAegis: owner is not an AegisTower", Verbose.Category.ENTITY_MODULE)
		return

	var shield: float = tower.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
	for ally: Entity in tower.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius):
		if is_instance_valid(ally):
			tower.alterations.direct_stack(ally, shield, Alteration.Type.SHIELD, &"Bastion Aegis")


func get_description() -> String:
	return "Donne à tous les alliés proches un [[SHIELD]] égal à " + _value(_ap_ratio * 100) \
		+ "% de sa puissance magique."
