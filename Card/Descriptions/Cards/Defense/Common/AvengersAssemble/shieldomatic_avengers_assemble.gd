class_name DefenseAvengersAssemble
extends HeroUpgrade

@export var _crit_chance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.LEGENDARY


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Avengers Assemble: Wrong card_lvl: ", card_lvl)
		return

	var mod := StatModifier.new()
	mod.id = &"Avengers Assemble"
	mod.stat_type = EntityStats.StatType.CRIT_CHANCE
	mod.action_type = Utils.ActionType.STACK_SHIELD
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _crit_chance[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Avengers Assemble: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "[[SHIELD]] gains have " + str(_crit_chance[cardlvl - 1]) + "% chance to crit"
