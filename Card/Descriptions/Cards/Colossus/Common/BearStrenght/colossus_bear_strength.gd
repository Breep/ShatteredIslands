class_name ColossusBearStrength
extends HeroUpgrade

@export var _as_reduction: Array[float]
@export var _hp_to_ad_percent: Array[float]
@export var _size_to_ad_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	# Reduce attack speed
	var as_mod := StatModifier.new()
	as_mod.id = &"Bear Strength AS"
	as_mod.stat_type = EntityStats.StatType.AS
	as_mod.calc_type = StatModifier.CalcType.MULT
	as_mod.value = -(_as_reduction[card_lvl - 1] / 100.0)
	as_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(as_mod)

	# Increase AD by % of max HP and size
	var max_hp: float = float(ctx.hero.stats.health_max)
	var hp_percent: float = _hp_to_ad_percent[card_lvl - 1]
	var size_percent: float = _size_to_ad_percent[card_lvl - 1]

	var ad_mod := StatModifier.new()
	ad_mod.id = &"Bear Strength AD"
	ad_mod.stat_type = EntityStats.StatType.AD
	ad_mod.calc_type = StatModifier.CalcType.ADD
	ad_mod.value = max_hp * (hp_percent / 100.0) + (ctx.hero.scale[1] - 1) * (size_percent / 100.0) # -1 if base_size is 1
	#TODO add a base_size for all heroes?
	ad_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(ad_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Bear Strength: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Decrease attack speed by " + str(_as_reduction[cardlvl - 1]) + "%. Increase AD by " + str(_hp_to_ad_percent[cardlvl - 1]) + "% max HP."
