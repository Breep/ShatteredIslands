class_name PoisonTideOfCorruption
extends HeroUpgrade

@export var _multiplier: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of Corruption: Wrong card_lvl: ", card_lvl)
		return

	var multiplier: float = _multiplier[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Tide of Corruption", period, func() -> void:
		var targets: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		if targets.is_empty(): return
		var target_number: int = targets.size()
		var poison_stacks: int = int(multiplier * float(target_number))
		for target in targets:
			ctx.hero.inflict_condition_stacks(target, poison_stacks, Stack.Type.POISON, &"Tide of Corruption")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of corruption: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_multiplier[cardlvl - 1]) + "* <enemies alive> [[POISON_STACK]] " \
			+ " to all enemies"
