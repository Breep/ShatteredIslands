class_name StormStormBattery
extends CardEffect

@export var _base_mana_gain: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Battery: Wrong card_lvl: ", card_lvl)
		return

	var base_mana: float = _base_mana_gain[card_lvl - 1]

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.add_card_item(ctx.card_id, storm_stats.on_lightning_callbacks,
		func(_target: Entity, _rank: StormCallerManager.Rank, rank_mult: float) -> void:
			if ctx.hero == null or not is_instance_valid(ctx.hero): return
			var final_mana: float = base_mana * rank_mult
			if final_mana > 0:
				ctx.hero.stats.mana += final_mana
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.storm_caller.remove_card_items(ctx.card_id)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Battery: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each Lightning cast generates " + str(_base_mana_gain[cardlvl - 1]) + " * (Rank Value) mana"
