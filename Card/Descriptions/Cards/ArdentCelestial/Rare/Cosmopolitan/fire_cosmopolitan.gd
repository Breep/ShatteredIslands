class_name FireCosmopolitan
extends HeroUpgrade

@export var _ignite_stacks_multipliers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("FireCosmopolitan: Wrong card_lvl: ", card_lvl)
		return

	var ignite_stacks_multiplier: float = _ignite_stacks_multipliers[card_lvl - 1]

	# Phase 5 rework: STRENGTH is now a StrengthAlteration stack.
	if ctx.hero.conditions != null:
		ctx.hero.conditions.add_strength_stacks(Utils.ActionType.STACK_IGNITE, ignite_stacks_multiplier)
	



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"


	return "Augmente les stacks d'[[IGNITE]] appliquées de " + str(_ignite_stacks_multipliers[cardlvl - 1]) + "%."
