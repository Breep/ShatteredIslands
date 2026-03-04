class_name FireEndOfTheWorld
extends HeroUpgrade

@export var _stack_multiplier: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("End Of The World: Wrong card_lvl: ", card_lvl)
		return

	var multiplier: float = _stack_multiplier[card_lvl - 1]

	ctx.hero.families_stats.ardent_celestial.meteor_modifiers.append(func(cb_vars: Dictionary) -> void:
		var entities_inside: Array = cb_vars.get(Meteor.VarType.ENTITIES_INSIDE, [])
		for entity: Entity in entities_inside:
			if entity.team != ctx.hero.team:
				var hp: float = entity.stats.health
				var ignite_stacks: float = entity.conditions.ignite_stacks
				if hp <= ignite_stacks * multiplier:
					entity.stats.health = 0
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("End Of The World: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Meteor execute enemies below " + str(_stack_multiplier[cardlvl - 1]) + " * [[IGNITE_STACK]]"
