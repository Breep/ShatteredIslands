class_name SE_Shockwave
extends SkillEffect

# Bronze "Onde de choc": each time the dragon lands (Vol fracassant passive),
# stun every enemy on the board.

@export var _stun_duration: float = 3.0

func apply(ctx: SkillContext) -> void:
	var dragon: SkeletonDragon = ctx.entity as SkeletonDragon
	if dragon == null:
		Verbose.error("SE_Shockwave: owner is not a SkeletonDragon", Verbose.Category.ENTITY_MODULE)
		return
	var ability: ShatteringFlightAbility = dragon.get_flight_ability()
	if ability == null:
		Verbose.error("SE_Shockwave: dragon has no flight ability", Verbose.Category.ENTITY_MODULE)
		return

	ability.flight_landing_impact.connect(func() -> void:
		for enemy: Entity in dragon.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
			if is_instance_valid(enemy):
				dragon.alterations.inflict_status(enemy, Alteration.Type.STUN, _stun_duration, &"Shockwave")
	)
