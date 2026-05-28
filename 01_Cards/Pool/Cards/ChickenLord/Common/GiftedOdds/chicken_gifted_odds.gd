class_name ChickenGiftedOdds
extends CardEffect

@export var _gifted_chances_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var gifted_chance_increase: float = _gifted_chances_increase[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.gifted_chance_increase = gifted_chance_increase


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gifted Odds: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente la chance d'apparition de poulet doué de " + str(_gifted_chances_increase[cardlvl - 1]) + "%."
