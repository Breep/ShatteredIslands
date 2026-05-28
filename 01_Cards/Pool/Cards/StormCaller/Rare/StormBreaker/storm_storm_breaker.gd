class_name StormStormBreaker
extends CardEffect

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
			if target.alterations == null: return
			var added_percent: float = base_percent * rank_mult
			if added_percent <= 0: return

			target.alterations.add_typed_stack(Alteration.Type.VULNERABILITY, Utils.ActionType.DAMAGE_PHYSICAL, added_percent)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Breaker: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each Lightning cast applies " + str(_base_reduction_percent[cardlvl - 1]) + "% * Rank Value [[VULNERABILITY]] to target."
