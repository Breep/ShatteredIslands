class_name ArdentCelestialArmagedheal
extends HeroUpgrade

@export var _heal: Array[int]
@export var _proc_chance: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Armagedheal: Wrong card_lvl: ", card_lvl)
		return

	var heal: int = _heal[card_lvl - 1]
	
	ctx.hero.families_stats.ardent_celestial.meteor_on_hit_callbacks.append(func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(_proc_chance[card_lvl - 1]): return
		var target: Entity = ctx.hero.target.get_target(TargetModule.TargettingStrategy.RANDOM_HERO_ALLY)
		ctx.hero.heal.direct(target, heal, "Armagedheal")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Armagedheal: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Chaque [[METEOR]] a " + str(_proc_chance[cardlvl - 1]) + "% de chance de soigner un allié aléatoire de " + str(_heal[cardlvl - 1]) + "."
