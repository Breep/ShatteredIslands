class_name SE_OmeletteAstrale
extends SkillEffect

# Ultimate "Omelette astrale": applique AP x _ap_ignite_ratio Ignite à la cible principale.

@export var _ap_ignite_ratio: float = 1.0


func apply(ctx: SkillContext) -> void:
	var chicken: Entity = ctx.entity
	var target: Entity = chicken.auto_attack.get_current_target() if chicken.auto_attack != null else null
	if not is_instance_valid(target):
		target = chicken.target.get_target(TargetComponent.TargettingStrategy.CLOSEST_ENEMY)
	if not is_instance_valid(target):
		return
	var ignite: float = chicken.stats.get_stat(EntityStats.StatType.AP) * _ap_ignite_ratio
	chicken.alterations.inflict_condition_stacks(target, ignite, Alteration.Type.IGNITE, &"Omelette astrale")


func get_description() -> String:
	return "Applique [[IGNITE]] égal à " + _value(_ap_ignite_ratio) + "× son [[AP]] à sa cible."
