class_name ColossusCrystalMountain
extends HeroUpgrade

@export var _defense_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var defense_val: float = _defense_increase[card_lvl - 1]
	if ctx.hero.alterations_module != null:
		ctx.hero.alterations_module.add_defense_stacks(defense_val)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente la [[DEFENCE]] de " + str(_defense_increase[cardlvl - 1]) + "."
