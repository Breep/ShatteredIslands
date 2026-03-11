class_name ColossusVitalPulse
extends HeroUpgrade

@export var _period: Array[float]
@export var _damage_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var percent: float = _damage_percent[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Vital Pulse", period, func() -> void:
		var targets: Array[Entity] = ctx.hero.target_module.get_targets(
			TargetModule.MultipleTargettingStrategy.ENEMIES
		)
		if targets.is_empty():
			return

		var max_hp: float = ctx.hero.stats.health_max
		var damage: float = max_hp * (percent / 100.0)
		if damage <= 0:
			return

		for target in targets:
			if target != null and is_instance_valid(target):
				ctx.hero.direct_damage(target, damage, Utils.DamageType.PHYSICAL, &"Vital Pulse")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Vital Pulse: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + " sec, deal " + str(_damage_percent[cardlvl - 1]) + "% current HP as physical damage to all enemies."
