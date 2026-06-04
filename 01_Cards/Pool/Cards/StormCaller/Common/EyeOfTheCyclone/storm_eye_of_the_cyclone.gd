class_name StormEyeOfTheCyclone
extends CardEffect

@export var _base_max_hp_percent_bonus: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Eye of the Cyclone: Wrong card_lvl: ", card_lvl)
		return

	var hp_percent: float = _base_max_hp_percent_bonus[card_lvl - 1]
	var state := {&"accumulated": 0.0}

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.add_card_item(ctx.card_id, storm_stats.on_rank_s_callbacks,
		func(_rank_mult: float) -> void:
			var max_hp_bonus: float = ctx.hero.stats.health_max * (hp_percent / 100.0)
			state[&"accumulated"] += max_hp_bonus

			var mod := StatModifier.new()
			mod.id = &"Eye of the Cyclone"
			mod.stat_type = EntityStats.StatType.HEALTH_MAX
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = state[&"accumulated"]
			mod.tags = [StatModifier.TagType.CARD]
			ctx.stat_modifiers.register_modifier(mod)

			ctx.hero.heal.direct(ctx.hero, max_hp_bonus, &"Eye of the Cyclone")
	)

	# Reset accumulated bonus each battle
	ctx.battle_callbacks.register_battle_start(&"Eye of the Cyclone", func() -> void:
		state[&"accumulated"] = 0.0
		ctx.stat_modifiers.remove_modifier(EntityStats.StatType.HEALTH_MAX, &"Eye of the Cyclone")
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.storm_caller.remove_card_items(ctx.card_id)
	ctx.battle_callbacks.unregister_all(&"Eye of the Cyclone")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Eye of the Cyclone: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "On rank S, gain " + str(_base_max_hp_percent_bonus[cardlvl - 1]) + "% Max HP and heal for the same amount"
