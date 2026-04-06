class_name FireCosmopolitan
extends HeroUpgrade

@export var _ignite_stacks_multipliers: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("FireCosmopolitan: Wrong card_lvl: ", card_lvl)
		return

	var ignite_stacks_multiplier: float = _ignite_stacks_multipliers[card_lvl - 1]
	
	var mod := StatModifier.new()
	mod.id = &"Cosmopolitan"
	mod.stat_type = EntityStats.StatType.STRENGTH
	mod.action_type = Utils.ActionType.STACK_IGNITE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = ignite_stacks_multiplier
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)
	



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"


	return "Augmente les stacks d'[[IGNITE]] appliquées de " + str(_ignite_stacks_multipliers[cardlvl - 1]) + "%."
