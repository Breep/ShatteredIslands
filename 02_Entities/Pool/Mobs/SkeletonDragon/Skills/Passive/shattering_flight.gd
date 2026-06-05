class_name SE_ShatteringFlight
extends SkillEffect

# Passive "Vol fracassant": each time the dragon's HP first drops at or below a new
# threshold (80/60/40/20 %), it takes off (ShatteringFlightAbility) and deals heavy
# magical damage to every enemy on the landing's ground-contact frame.
# A high-water mark (count of crossed thresholds) means: crossing several at once flies
# only once, and healing back up then re-crossing never re-triggers an already-passed one.

@export var _thresholds_percent: Array[float] = [80.0, 60.0, 40.0, 20.0]
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

	# Boxed so the state lives per-applied-instance (the SkillEffect resource may be
	# shared between several dragons via entity_desc).
	var crossed_count: Array[int] = [0]

	dragon.stats.health_changed.connect(func(_new_hp: float) -> void:
		if dragon.stats.health_max <= 0.0:
			return
		var hp_percent: float = dragon.stats.health / dragon.stats.health_max * 100.0
		var count: int = 0
		for threshold: float in _thresholds_percent:
			if hp_percent <= threshold:
				count += 1
		if count > crossed_count[0]:
			crossed_count[0] = count
			dragon.start_flight()
	)

	ability.flight_landing_impact.connect(func() -> void:
		for enemy: Entity in dragon.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES):
			if is_instance_valid(enemy):
				dragon.damage.direct(enemy, _landing_damage, Utils.ActionType.DAMAGE_MAGICAL, &"ShatteringFlight")
	)
