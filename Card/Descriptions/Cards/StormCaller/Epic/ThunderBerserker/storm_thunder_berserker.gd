class_name StormThunderBerserker
extends HeroUpgrade

@export var _start_boost: Array[float]
@export var _delay: Array[float]
@export var _penalty_per_rank: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Berserker: Wrong card_lvl: ", card_lvl)
		return

	var boost: float = _start_boost[card_lvl - 1]
	var delay: float = _delay[card_lvl - 1]
	var penalty: float = _penalty_per_rank[card_lvl - 1]
	var state := {&"penalty_active": false, &"accumulated": 0.0}

	# Initial crit mult boost (registered once, always active)
	var boost_mod := StatModifier.new()
	boost_mod.id = &"Thunder Berserker Boost"
	boost_mod.stat_type = EntityStats.StatType.CRIT_MULT
	boost_mod.calc_type = StatModifier.CalcType.ADD
	boost_mod.value = boost
	boost_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(boost_mod)

	# On rank change: if penalty phase active, accumulate crit mult penalty
	var storm_stats: FamilyStormStats = ctx.hero.families_stats.storm
	storm_stats.on_rank_change_callbacks.append(
		func(_rank: StormCallerManager.Rank, _rank_mult: float) -> void:
			if not state[&"penalty_active"]: return
			state[&"accumulated"] += penalty
			var mod := StatModifier.new()
			mod.id = &"Thunder Berserker Penalty"
			mod.stat_type = EntityStats.StatType.CRIT_MULT
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = -(state[&"accumulated"])
			mod.tags = [StatModifier.TagType.CARD]
			ctx.stat_modifiers.update_modifier(mod)
	)

	# Battle start: reset state + start delay timer
	ctx.battle_callbacks.register_battle_start(&"Thunder Berserker", func() -> void:
		state[&"penalty_active"] = false
		state[&"accumulated"] = 0.0
		# Remove any leftover penalty modifier
		ctx.stat_modifiers.remove_modifier(EntityStats.StatType.CRIT_MULT, &"Thunder Berserker Penalty")
		# Delay timer — after timeout, penalty phase begins
		var tree: SceneTree = ctx.hero.get_tree()
		if tree:
			tree.create_timer(delay).timeout.connect(func() -> void:
				state[&"penalty_active"] = true
			)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Berserker: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "When battle start, increase [[CRIT_MULTIPLIER]] by " + str(_start_boost[cardlvl - 1]) + "%. After " + str(_delay[cardlvl - 1]) + "s, your [[CRIT_MULTIPLIER]] decreases by " + str(_penalty_per_rank[cardlvl - 1]) + "% after each [[RANK]] grind."
