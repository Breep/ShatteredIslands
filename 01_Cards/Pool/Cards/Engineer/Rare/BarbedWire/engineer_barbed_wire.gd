class_name EngineerBarbedWire
extends CardEffect

@export var _thorns: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Barbed Wire: Wrong card_lvl: ", card_lvl)
		return
	
	if ctx.hero.alterations != null:
		ctx.hero.alterations.add_stack(Alteration.Type.THORN, _thorns[card_lvl - 1])


func revert_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return
	if ctx.hero.alterations != null:
		ctx.hero.alterations.remove_stack(Alteration.Type.THORN, _thorns[card_lvl - 1])


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Barbed Wire: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var thorn: String = str(_thorns[cardlvl - 1]).pad_decimals(0)
	return "Gagne " + thorn + " épines tant que vous avez du [[SHIELD]]."
