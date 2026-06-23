class_name SE_RelaisBasseCour
extends SkillEffect

# Ultimate "Relais de basse-cour": donne AP x _ap_ratio Shield à l'allié le plus blessé
# dans un rayon _radius.

@export var _ap_ratio: float = 2.0
@export var _radius: float = 6.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var best: Entity = null
	var best_pct: float = INF
	for ally: Entity in chicken.target.get_targets(TargetComponent.MultipleTargettingStrategy.ALLIES, _radius):
		if ally.stats.health_max <= 0.0:
			continue
		var pct: float = ally.stats.health / ally.stats.health_max
		if pct < best_pct:
			best_pct = pct
			best = ally
	if is_instance_valid(best):
		var shield: float = chicken.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
		chicken.alterations.direct_stack(best, shield, Alteration.Type.SHIELD, &"Relais de basse-cour")


func get_description() -> String:
	return "Donne [[SHIELD]] égal à " + _value(_ap_ratio) + "× son [[AP]] à l'allié le plus blessé " \
		+ "dans un rayon de " + _value(_radius) + "."
