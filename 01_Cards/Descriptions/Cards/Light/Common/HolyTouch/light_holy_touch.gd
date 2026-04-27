class_name LightHolyTouch
extends HeroUpgrade

@export var _heal_amount: Array[int]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Holy Touch: Wrong card_lvl: ", card_lvl)
		return

	var amount: int = _heal_amount[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Holy Touch", period, func() -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		if target == null: return
		ctx.hero.heal.direct(target, amount, &"Holy Touch")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Holy Touch: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Heals lowest hp ally for " + str(_heal_amount[cardlvl-1]) +" HP every " + str(_period[cardlvl-1]) + " s"
