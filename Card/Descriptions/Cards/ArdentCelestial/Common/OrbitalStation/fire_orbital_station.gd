class_name FireOrbitalStation
extends HeroUpgrade

@export var _crit_chance: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Orbital Station: Wrong card_lvl: ", card_lvl)
		return

	var mod := StatModifier.new()
	mod.id = &"Orbital Station"
	mod.stat_type = EntityStats.StatType.CRIT_CHANCE
	mod.action_type = Utils.ActionType.STACK_IGNITE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _crit_chance[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Orbital Station: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Your [[IGNITE]] applications have " + str(_crit_chance[cardlvl - 1]) + "% chance to crit"
