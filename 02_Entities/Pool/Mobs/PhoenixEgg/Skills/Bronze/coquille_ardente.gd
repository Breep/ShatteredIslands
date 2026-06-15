class_name SE_CoquilleArdente
extends SkillEffect

# Talent "Coquille ardente": tant que l'œuf existe, il applique AP x _ap_ratio Ignite par
# seconde aux ennemis dans un rayon _radius.

@export var _ap_ratio: float = 0.30
@export var _radius: float = 3.0
@export var _period: float = 1.0


func apply(ctx: SkillContext) -> void:
	var egg: Entity = ctx.entity
	egg.battle_callback_registry.register_periodic(&"CoquilleArdente", _period, func() -> void:
		var ignite: float = egg.stats.get_stat(EntityStats.StatType.AP) * _ap_ratio
		for enemy: Entity in egg.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES, _radius):
			egg.alterations.inflict_condition_stacks(enemy, ignite, Alteration.Type.IGNITE, &"Coquille ardente")
	, true)
