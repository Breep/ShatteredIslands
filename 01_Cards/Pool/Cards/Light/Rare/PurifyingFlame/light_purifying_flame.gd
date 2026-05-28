class_name LightPurifyingFlame
extends CardEffect

@export var _cleanse_amount: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Purifying Flame: Wrong card_lvl: ", card_lvl)
		return

	var amount: float = _cleanse_amount[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Purifying Flame", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)
		if target == null: return
		ctx.hero.alterations.cleanse(target, amount, &"Purifying Flame")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Purifying Flame: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Every " + str(_period[0]) + "s, cleanse " + str(_cleanse_amount[cardlvl - 1]) + " negative effects on lowest hp hero ally."
