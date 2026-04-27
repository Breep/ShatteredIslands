class_name NecroPutridTouch
extends HeroUpgrade

@export var _stacks: Array[int]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Putrid Touch: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = _stacks[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.periodic_timers.register(&"Putrid Touch", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ENEMY)
		if target == null: return
		ctx.hero.alterations.inflict_condition_stacks(target, stacks, Alteration.Type.NECROSIS, &"Putrid Touch")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Putrid Touch: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[cardlvl - 1]) + "s, apply " + str(_stacks[cardlvl - 1]) + " stacks of [[NECROSIS]] to a random enemy."
