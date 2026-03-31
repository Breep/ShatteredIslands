class_name FireNuke
extends HeroUpgrade

@export var _ignite_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = _ignite_stacks[card_lvl - 1]
	
	ctx.hero.periodic_timer_registry.register_oneshot(0.2, func() -> void:
		var targets: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ENEMIES)
		for target: Entity in targets:
			ctx.hero.inflict_condition_stacks(target, stacks, Stack.Type.IGNITE, &"Nuke")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "At the beggining of fight apply " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE]] stacks to all enemies"
