class_name ChickenTwins
extends HeroUpgrade

@export var _chance: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var chance: float = _chance[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.twins_chance = chance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Twins: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Gives a chance to summon twins chickens by " + str(_chance[cardlvl - 1])
