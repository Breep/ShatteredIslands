class_name ColossusProteins
extends HeroUpgrade

@export var _max_hp_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_increase: float = _max_hp_increase[card_lvl - 1]

	var mod := StatModifier.new()
	mod.id = &"Proteins"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = hp_increase
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)

	# Also increase current HP to match (same as original ColossusManager logic)
	ctx.hero.stats.health += hp_increase


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Proteins: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase max HP by " + str(_max_hp_increase[cardlvl - 1])
