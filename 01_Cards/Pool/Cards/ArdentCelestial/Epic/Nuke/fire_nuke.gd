class_name FireNuke
extends CardEffect

@export var _ignite_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = _ignite_stacks[card_lvl - 1]
	
	ctx.hero.battle_callback_registry.register_oneshot(0.2, func() -> void:
		var targets: Array[Entity] = ctx.hero.target.get_targets(TargetComponent.MultipleTargettingStrategy.ENEMIES)
		for target: Entity in targets:
			ctx.hero.alterations.inflict_condition_stacks(target, stacks, Alteration.Type.IGNITE, &"Nuke")
	, &"Nuke")


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.battle_callback_registry.unregister_all(&"Nuke")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Au début du combat, applique " + str(_ignite_stacks[cardlvl - 1]) + " stacks d'[[IGNITE]] à tous les ennemis."
