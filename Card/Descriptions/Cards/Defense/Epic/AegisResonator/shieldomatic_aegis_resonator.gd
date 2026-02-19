class_name DefenseAegisResonator
extends HeroUpgrade

@export var _period: Array[float]
@export var _total_shield: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong card_lvl: ", card_lvl)
		return

	var period: float = _period[card_lvl - 1]
	var total_shield: float = _total_shield[card_lvl - 1]

	ctx.periodic_timers.register(&"Aegis Resonator", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
		if allies.is_empty():
			return
		var ally_count: int = allies.size()
		var shield_per_ally: int = int(total_shield / float(ally_count))
		if shield_per_ally <= 0:
			return
		for ally: Entity in allies:
			if ally != null and is_instance_valid(ally):
				if ally == ctx.hero:
					ctx.hero.inflict_condition_stacks(ctx.hero, shield_per_ally, Utils.StackType.SHIELD, &"Resonator")
				else:
					ally.conditions.shield_stacks += shield_per_ally
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, emit a pulse that gives " + str(_total_shield[cardlvl - 1]) + " [[SHIELD]], shared by all allies."
