class_name FireExpanseUniverse
extends CardEffect

@export var _ignite_stacks: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong card_lvl: ", card_lvl)
		return

	var stacks: int = int(_ignite_stacks[card_lvl - 1])
	var period: float = _period[card_lvl - 1]
	
	ctx.battle_callbacks.register_periodic(&"Expanse Universe", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.HIGHEST_HP_PERCENT_ENEMY)
		if target == null: return
		ctx.hero.alterations.inflict_condition_stacks(target, stacks, Alteration.Type.IGNITE, &"Expanse Universe")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Inflige " + str(_ignite_stacks[cardlvl - 1]) + " stacks d'[[IGNITE]] toutes les " + str(_period[cardlvl - 1]) + "s à l'ennemi avec le plus de PV."
