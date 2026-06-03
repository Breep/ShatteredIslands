class_name ColossusCrushingWeight
extends CardEffect

@export var _stun_increase_percents: Array[float]


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crushing Weight: Wrong card_lvl: ", card_lvl)
		return

	if ctx.hero.alterations != null:
		ctx.hero.alterations.add_typed_stack(Alteration.Type.STRENGTH, Utils.ActionType.STATUS_STUN, _stun_increase_percents[card_lvl - 1])



func revert_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return
	if ctx.hero.alterations != null:
		ctx.hero.alterations.remove_typed_stack(Alteration.Type.STRENGTH, Utils.ActionType.STATUS_STUN, _stun_increase_percents[card_lvl - 1])


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crushing Weight: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente la durée du [[STUN]] de " + str(_stun_increase_percents[cardlvl - 1]) + "%."
