class_name ColossusCrystalMountain
extends HeroUpgrade

@export var _defense_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var defense_val: float = _defense_increase[card_lvl - 1]

	# Physical resistance
	var phys_mod := StatModifier.new()
	phys_mod.id = &"Crystal Mountain (Phys)"
	phys_mod.stat_type = EntityStats.StatType.RESISTANCE
	phys_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	phys_mod.calc_type = StatModifier.CalcType.ADD
	phys_mod.value = defense_val
	phys_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(phys_mod)

	# Magical resistance
	var magic_mod := StatModifier.new()
	magic_mod.id = &"Crystal Mountain (Magic)"
	magic_mod.stat_type = EntityStats.StatType.RESISTANCE
	magic_mod.action_type = Utils.ActionType.DAMAGE_MAGICAL
	magic_mod.calc_type = StatModifier.CalcType.ADD
	magic_mod.value = defense_val
	magic_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(magic_mod)

	# Poison resistance
	var poison_mod := StatModifier.new()
	poison_mod.id = &"Crystal Mountain (Poison)"
	poison_mod.stat_type = EntityStats.StatType.RESISTANCE
	poison_mod.action_type = Utils.ActionType.DAMAGE_POISON
	poison_mod.calc_type = StatModifier.CalcType.ADD
	poison_mod.value = defense_val
	poison_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(poison_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase defense (Physical, Magical, Poison resist) by " + str(_defense_increase[cardlvl - 1])
