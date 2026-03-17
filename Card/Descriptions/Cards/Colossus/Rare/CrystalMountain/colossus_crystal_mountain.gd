class_name ColossusCrystalMountain
extends HeroUpgrade

@export var _defense_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var defense_val: float = _defense_increase[card_lvl - 1]

	var mod3 := StatModifier.new()
	mod3.id = &"Crystal Moutain"
	mod3.stat_type = EntityStats.StatType.DEFENCE
	mod3.calc_type = StatModifier.CalcType.ADD
	mod3.value = defense_val
	ctx.hero.stat_modifiers_registry.register_modifier(mod3)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase defense (Physical, Magical, Poison resist) by " + str(_defense_increase[cardlvl - 1])
