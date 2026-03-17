class_name StormDynamo
extends HeroUpgrade

@export var _base_regen: Array[float]
@export var _base_shield: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Dynamo: Wrong card_lvl: ", card_lvl)
		return

	var base_regen: float = _base_regen[card_lvl - 1]
	var base_shield: float = _base_shield[card_lvl - 1]

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.on_lightning_callbacks.append(
		func(_target: Entity, _rank: StormCallerManager.Rank, rank_mult: float) -> void:
			if ctx.hero == null or not is_instance_valid(ctx.hero): return
			var final_regen: float = base_regen * rank_mult
			if final_regen > 0:
				ctx.hero.inflict_condition_stacks(ctx.hero, final_regen, Stack.Type.REGEN, &"Dynamo")
			var final_shield: float = base_shield * rank_mult
			if final_shield > 0:
				ctx.hero.inflict_condition_stacks(ctx.hero, final_shield, Stack.Type.SHIELD, &"Dynamo")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Dynamo: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each Lightning cast apply " + str(_base_regen[cardlvl - 1]) + " regen and " + str(_base_shield[cardlvl - 1]) + " shield."
