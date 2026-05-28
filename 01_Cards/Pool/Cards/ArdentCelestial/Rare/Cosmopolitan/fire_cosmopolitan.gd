class_name FireCosmopolitan
extends CardEffect

@export var _ignite_stacks_multipliers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("FireCosmopolitan: Wrong card_lvl: ", card_lvl)
		return

	var ignite_stacks_multiplier: float = _ignite_stacks_multipliers[card_lvl - 1]

	if ctx.hero.alterations != null:
		ctx.hero.alterations.add_typed_stack(Alteration.Type.STRENGTH, Utils.ActionType.STACK_IGNITE, ignite_stacks_multiplier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"


	return "Augmente les stacks d'[[IGNITE]] appliquées de " + str(_ignite_stacks_multipliers[cardlvl - 1]) + "%."
