class_name ColossusCrushingWeight
extends HeroUpgrade

@export var _stun_increase_percents: Array[float]


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crushing Weight: Wrong card_lvl: ", card_lvl)
		return

	# Stat modifier: increase dodge vs physical damage
	var mod := StatModifier.new()
	mod.id = &"Crushing Weight"
	mod.stat_type = EntityStats.StatType.STRENGTH
	mod.action_type = Utils.ActionType.STATUS_STUN
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _stun_increase_percents[card_lvl - 1]
	print(str(_stun_increase_percents[card_lvl - 1]))
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crushing Weight: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase the duration of the stuns by " + str(_stun_increase_percents[cardlvl - 1]) + "%."
