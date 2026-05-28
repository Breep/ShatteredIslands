class_name PoisonPoisonFlask
extends CardEffect

@export var _poison_stacks: Array[int]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = _poison_stacks[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Poison Flask", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null: return
		ctx.hero.alterations.inflict_condition_stacks(target, stacks, Alteration.Type.POISON, &"Poison Flask")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Inflict " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]], every " + str(_period[cardlvl - 1]) + "s"
