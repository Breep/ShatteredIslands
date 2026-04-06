class_name EngineerGasMask
extends HeroUpgrade

@export var _base_efficiency: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gas Mask: Wrong card_lvl: ", card_lvl)
		return

	var efficiency: float = _base_efficiency[card_lvl - 1] / 100.0

	ctx.battle_callbacks.register_battle_start(&"Gas Mask", func() -> void:
		var shield_stack: ShieldStack = ctx.hero.conditions.get_shield_stack()
		shield_stack.set_efficiency(Utils.ActionType.DAMAGE_POISON, efficiency)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Gas Mask: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Le [[SHIELD]] bloque les dégâts de poison à " + str(_base_efficiency[cardlvl - 1]) + "% de sa valeur."
