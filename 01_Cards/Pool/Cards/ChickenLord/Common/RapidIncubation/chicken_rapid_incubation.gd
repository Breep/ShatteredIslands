class_name ChickenRapidIncubation
extends CardEffect

@export var _timer_decrease: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var timer_amount: float = _timer_decrease[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.spawn_period_decrease = timer_amount


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.chicken_lord.spawn_period_decrease = 0.0


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rapid Incubation: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Réduit le temps d'apparition des poulets de " + str(_timer_decrease[cardlvl - 1]) + "s."
