class_name SE_CendresTenaces
extends SkillEffect

# Talent "Cendres tenaces" (Phoenix): applique AP x _ap_ratio Ignite par seconde aux
# ennemis dans un rayon _radius.

@export var _ap_ratio: float = 0.75
@export var _radius: float = 3.0
@export var _period: float = 1.0


func apply(ctx: SkillContext) -> void:
	var phoenix: Entity = ctx.entity
	phoenix.battle_callback_registry.register_periodic(&"CendresTenaces", _period, func() -> void:
		var ignite: float = phoenix.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
		for enemy: Entity in phoenix.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			phoenix.alterations.direct_stack(enemy, ignite, Alteration.Type.IGNITE, &"Cendres tenaces")
	, true)


func get_description() -> String:
	return "Toutes les " + _value(_period) + " s, applique des stacks d'[[IGNITE]] égaux à " \
		+ _value(_ap_ratio * 100) + "% de sa puissance magique aux ennemis proches."
