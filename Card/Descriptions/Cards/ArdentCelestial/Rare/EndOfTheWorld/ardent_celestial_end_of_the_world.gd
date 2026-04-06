class_name ArdentCelestialEndOfTheWorld
extends HeroUpgrade

@export var _bonus_meteor_chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("End of the world: Wrong card_lvl: ", card_lvl)
		return
		
	var bonus_meteor_chance: float = _bonus_meteor_chances[card_lvl - 1]
	ctx.hero.families_stats.ardent_celestial.end_of_the_world_bonus_meteor_chance = bonus_meteor_chance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"
		printerr("End of the world: Wrong card_lvl: ", cardlvl)

	return "Augmente la chance d'apparition de [[METEOR]] de " + str(_bonus_meteor_chances[cardlvl - 1 ]) + "%."
