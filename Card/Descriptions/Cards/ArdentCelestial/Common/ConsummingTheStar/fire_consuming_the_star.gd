class_name FireConsumingTheStar
extends HeroUpgrade

@export var _mana_burn: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Consuming the Star: Wrong card_lvl: ", card_lvl)
		return

	var burn: float = _mana_burn[card_lvl - 1]

	ctx.hero.families_stats.ardent_celestial.meteor_modifiers.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity: Entity in entities_inside:
			if entity != null and is_instance_valid(entity) and entity.team != ctx.hero.team:
				if entity.stats.mana > 0:
					entity.stats.mana = max(0.0, entity.stats.mana - burn)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Consuming the Star: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every [[METEOR]] burns " + str(_mana_burn[cardlvl - 1]) + " mana to enemies hit."
