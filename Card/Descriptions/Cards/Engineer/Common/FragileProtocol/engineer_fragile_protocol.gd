class_name EngineerFragileProtocol
extends HeroUpgrade

@export var _heal_resistance: Array[float]
@export var _shield_power: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong card_lvl: ", card_lvl)
		return
	
	if ctx.hero.alterations_module != null:
		ctx.hero.alterations_module.add_weakness_stacks(Utils.ActionType.UTILITY_HEAL, _heal_resistance[card_lvl - 1])
		ctx.hero.alterations_module.add_strength_stacks(Utils.ActionType.STACK_SHIELD, _shield_power[card_lvl - 1])


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var heal_reduction: String = str(_heal_resistance[cardlvl - 1]).pad_decimals(0)
	var shield_power: String = str(_shield_power[cardlvl - 1]).pad_decimals(0)
	return "Réduit le soin de " + heal_reduction + ". Gagne " + shield_power + " de puissance de [[SHIELD]]."
