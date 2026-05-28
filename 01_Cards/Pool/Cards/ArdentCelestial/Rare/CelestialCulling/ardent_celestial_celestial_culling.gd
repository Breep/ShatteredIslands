class_name ArdentCelestialCelestialCulling
extends CardEffect

@export var _thresholds: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Celestial Culling: Wrong card_lvl: ", card_lvl)
		return

	var threshold: float = _thresholds[card_lvl - 1]

	ctx.hero.families_stats.ardent_celestial.meteor_on_hit_callbacks.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity: Entity in entities_inside:
			if entity.team != ctx.hero.team:
				var hp: float = entity.stats.health
				var hp_max: float = entity.stats.health_max
				if hp <= hp_max * threshold/100:
					entity.stats.health = 0
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Celestial Culling: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Le [[METEOR]] exécute les ennemis en dessous de " + str(_thresholds[cardlvl - 1]) + "% de leurs PV max."
