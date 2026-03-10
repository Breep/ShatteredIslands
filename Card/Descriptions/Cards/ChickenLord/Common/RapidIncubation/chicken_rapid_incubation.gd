class_name ChickenRapidIncubation
extends HeroUpgrade

@export var _timer_decrease: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var timer_amount: float = _timer_decrease[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.spawn_period_decrease = timer_amount


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rapid Incubation: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Decreased the spawn timer of the chickens by " + str(_timer_decrease[cardlvl - 1]) + " seconds"
