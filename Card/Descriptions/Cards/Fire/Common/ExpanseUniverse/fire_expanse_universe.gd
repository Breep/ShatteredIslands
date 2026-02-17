class_name FireExpanseUniverse
extends HeroUpgrade

@export var _ignite_stacks: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = int(_ignite_stacks[card_lvl - 1])
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Expanse Universe", period, func() -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY)
		if target == null: return
		ctx.hero.inflict_condition_stacks(target, stacks, Utils.StackType.IGNITE, &"Expanse Universe")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Inflict " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE]] stacks every " + str(_period[cardlvl - 1]) + "s."
