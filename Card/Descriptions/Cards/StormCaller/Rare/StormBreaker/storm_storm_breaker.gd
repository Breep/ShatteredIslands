class_name StormStormBreaker
extends HeroUpgrade

@export var _base_reduction_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Breaker: Wrong card_lvl: ", card_lvl)
		return

	var base_percent: float = _base_reduction_percent[card_lvl - 1]

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.on_lightning_callbacks.append(
		func(target: Entity, _rank: StormCallerManager.Rank, rank_mult: float) -> void:
			if target == null or not is_instance_valid(target): return
			if target.stat_modifiers_registry == null: return
			var added_percent: float = base_percent * rank_mult
			if added_percent <= 0: return

			var current_total: float = 0.0
			if storm_stats.storm_breaker_memory.has(target):
				current_total = storm_stats.storm_breaker_memory[target]
			var new_total: float = current_total + added_percent
			storm_stats.storm_breaker_memory[target] = new_total

			var mod := StatModifier.new()
			mod.id = &"Storm Breaker"
			mod.stat_type = EntityStats.StatType.VULNERABILITY
			mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = new_total
			mod.tags = [StatModifier.TagType.CARD]
			target.stat_modifiers_registry.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Breaker: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each Lightning cast applies " + str(_base_reduction_percent[cardlvl - 1]) + "% * Rank Value [[VULNERABILITY]] to target."
