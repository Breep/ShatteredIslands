class_name EngineerEnergyBarrier
extends HeroUpgrade

@export var _shield_amount: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Energy Barrier: Wrong card_lvl: ", card_lvl)
		return

	var amount: int = int(_shield_amount[card_lvl - 1])
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Energy Barrier", period, func() -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		ctx.hero.inflict_condition_stacks(ctx.hero, amount, Stack.Type.SHIELD, &"Energy Barrier")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Energy Barrier: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Génère " + str(_shield_amount[cardlvl - 1]) + " [[SHIELD]] toutes les " + str(_period[cardlvl - 1]) + "s."
