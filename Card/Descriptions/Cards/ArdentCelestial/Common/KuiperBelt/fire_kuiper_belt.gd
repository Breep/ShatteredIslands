class_name FireKuiperBelt
extends HeroUpgrade

@export var _shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong card_lvl: ", card_lvl)
		return

	var shield: int = int(_shield_amount[card_lvl - 1])

	ctx.hero.families_stats.fire.meteor_modifiers.append(func(_cb_vars: Dictionary) -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero): return
		if shield > 0:
			ctx.hero.inflict_condition_stacks(ctx.hero, shield, Stack.Type.SHIELD, &"Kuiper Belt")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Gain " + str(_shield_amount[cardlvl - 1]) + " [[SHIELD]] per [[METEOR]] spawn"
