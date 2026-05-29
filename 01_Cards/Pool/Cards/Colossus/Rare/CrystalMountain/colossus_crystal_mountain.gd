class_name ColossusCrystalMountain
extends CardEffect

@export var _defense_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var defense_val: float = _defense_increase[card_lvl - 1]
	if ctx.hero.alterations != null:
		ctx.hero.alterations.add_stack(Alteration.Type.DEFENSE, defense_val)


func revert_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return
	if ctx.hero.alterations != null:
		ctx.hero.alterations.remove_stack(Alteration.Type.DEFENSE, _defense_increase[card_lvl - 1])


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente la [[DEFENCE]] de " + str(_defense_increase[cardlvl - 1]) + "."
