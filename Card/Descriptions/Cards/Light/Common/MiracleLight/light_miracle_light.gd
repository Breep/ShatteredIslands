class_name MiracleLight
extends HeroUpgrade

@export var _crit_chance_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Miracle Light: Wrong card_lvl: ", card_lvl)
		return

	var crit_bonus: float = _crit_chance_percent[card_lvl - 1]

	for action_type: Utils.ActionType in [Utils.ActionType.UTILITY_HEAL, Utils.ActionType.UTILITY_CLEANSE, Utils.ActionType.STACK_REGEN]:
		var mod := StatModifier.new()
		mod.id = &"Miracle Light"
		mod.stat_type = EntityStats.StatType.CRIT_CHANCE
		mod.action_type = action_type
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = crit_bonus
		mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Miracle Light: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Your Heals/Cleanse/Regen have " + str(_crit_chance_percent[cardlvl - 1]) + "% Chance to crit."
