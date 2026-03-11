class_name EngineerAbsorptionMatrix
extends HeroUpgrade

@export var _base_chance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Absorption Matrix: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]

	ctx.battle_callbacks.register_battle_start(&"Absorption Matrix", func() -> void:
		var shield_stack: ShieldStack = ctx.hero.conditions.get_shield_stack()
		shield_stack.set_free_use_chance(chance)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Absorption Matrix: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_base_chance[cardlvl - 1]) + "% chance for shield to not be consumed when received damage"
