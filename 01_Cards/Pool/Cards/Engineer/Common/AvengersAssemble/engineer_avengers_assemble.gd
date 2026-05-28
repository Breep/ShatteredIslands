class_name EngineerAvengersAssemble
extends CardEffect

@export var _crit_chance: Array[float]

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


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.stat_modifiers.remove_modifier(EntityStats.StatType.CRIT_CHANCE, &"Avengers Assemble")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Avengers Assemble: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Les gains de [[SHIELD]] ont " + str(_crit_chance[cardlvl - 1]) + "% de chance de crit."
