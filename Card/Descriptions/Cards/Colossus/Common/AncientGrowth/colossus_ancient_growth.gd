class_name ColossusAncientGrowth
extends HeroUpgrade

@export var _hp_increase: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_amount: float = _hp_increase[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	var state := {&"total_bonus": 0.0}

	# Register the initial stat modifier (value 0 — updated each tick)
	var mod := StatModifier.new()
	mod.id = &"Ancient Growth"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = 0.0
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)

	ctx.battle_callbacks.register_battle_start(&"Ancient Growth", func() -> void:
		state[&"total_bonus"] = 0.0
		mod.value = 0.0
		ctx.stat_modifiers.register_modifier(mod)
	)

	ctx.periodic_timers.register(&"Ancient Growth", period, func() -> void:
		state[&"total_bonus"] += hp_amount
		mod.value = state[&"total_bonus"]
		ctx.stat_modifiers.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Ancient Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase max HP by " + str(_hp_increase[cardlvl - 1]) + " every " + str(_period[0]) + " seconds"
