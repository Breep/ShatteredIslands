class_name SE_ShatteringFlight
extends SkillEffect

# Passive "Vol fracassant": every _hp_loss_trigger_percent of max HP lost, the
# dragon takes off (ShatteringFlightAbility) and deals heavy magical damage to
# every enemy on the ground-contact frame of the landing.

@export var _hp_loss_trigger_percent: float = 20.0
@export var _landing_damage: float = 100.0

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_ShatteringFlight: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability == null:
		Verbose.error("SE_ShatteringFlight: dragon has no flight ability", Verbose.Category.ENTITY_MODULE)
		return

	# State boxed in an array so it lives per-applied-instance (the SkillEffect
	# resource itself may be shared between several dragons via entity_desc).
	var brackets_fired: Array[int] = [0]
	var step: float = _hp_loss_trigger_percent / 100.0

	dragon.stats.health_changed.connect(func(_new_hp: float) -> void:
		if dragon.stats.health_max <= 0.0:
			return
		var lost_ratio: float = (dragon.stats.health_max - dragon.stats.health) / dragon.stats.health_max
		var brackets: int = floori(lost_ratio / step)
		if brackets > brackets_fired[0]:
			brackets_fired[0] = brackets
			dragon.start_flight()
	)

	ability.flight_landing_impact.connect(func() -> void:
		for enemy: Entity in dragon.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
			if is_instance_valid(enemy):
				dragon.damage.direct(enemy, _landing_damage, Utils.ActionType.DAMAGE_MAGICAL, &"ShatteringFlight")
	)
