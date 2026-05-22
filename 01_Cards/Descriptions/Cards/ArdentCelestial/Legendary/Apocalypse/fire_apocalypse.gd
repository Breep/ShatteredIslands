class_name FireApocalypse
extends HeroUpgrade

@export var _meteor_bonus_chance: Array[float]


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Apocalypse: Wrong card_lvl: ", card_lvl)
		return

	var meteor_bonus_chance: float = _meteor_bonus_chance[card_lvl - 1]
	
	ctx.hero.battle_callback_registry.register_periodic(&"Apocalypse", 1, func() -> void:
		ctx.hero.families_stats.ardent_celestial.apocalypse_bonus_meteor_chance += meteor_bonus_chance
	)
	


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Apocalypse: Wrong card_lvl: ", cardlvl)
		return "ERROR"
		
	return "Chaque seconde, augmente la chance d'apparition de [[METEOR]] de " + str(_meteor_bonus_chance[cardlvl - 1]) + "%."
