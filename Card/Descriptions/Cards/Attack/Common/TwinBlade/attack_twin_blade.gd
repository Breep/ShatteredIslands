class_name TwinBlade
extends HeroUpgrade

@export var _attack_speed_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Twin Blade: Wrong card_lvl: ", card_lvl)
		return

	var mod := StatModifier.new()
	mod.id = &"Twin Blade"
	mod.stat_type = EntityStats.StatType.AA_SPEED
	mod.calc_type = StatModifier.CalcType.MULT
	mod.value = _attack_speed_percent[card_lvl - 1] / 100.0
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Twin Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase attack speed by " + str(_attack_speed_percent[cardlvl - 1]) + "%."
