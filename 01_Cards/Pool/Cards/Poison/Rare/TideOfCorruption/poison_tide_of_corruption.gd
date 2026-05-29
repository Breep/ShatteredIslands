class_name PoisonTideOfCorruption
extends CardEffect

@export var _multiplier: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of Corruption: Wrong card_lvl: ", card_lvl)
		return

	var multiplier: float = _multiplier[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Tide of Corruption", period, func() -> void:
		var targets: Array[Entity] = ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES)
		if targets.is_empty(): return
		var target_number: int = targets.size()
		var poison_stacks: int = int(multiplier * float(target_number))
		for target in targets:
			ctx.hero.alterations.inflict_condition_stacks(target, poison_stacks, Alteration.Type.POISON, &"Tide of Corruption")
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Tide of Corruption")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of corruption: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_multiplier[cardlvl - 1]) + "* <enemies alive> [[POISON_STACK]] " \
			+ " to all enemies"
