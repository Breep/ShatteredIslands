class_name StormFaraday
extends CardEffect

@export var _base_crit_chance_boost: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Faraday: Wrong card_lvl: ", card_lvl)
		return

	var boost: float = _base_crit_chance_boost[card_lvl - 1]
	for action_type in Utils.get_all_actions():
		var mod := StatModifier.new()
		mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		mod.action_type = action_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.id = &"Faraday"
		mod.tags = [StatModifier.TagType.CARD]
		mod.value = boost
		ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Faraday: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increases Crit Chance by " + str(_base_crit_chance_boost[cardlvl - 1]) + "%"
