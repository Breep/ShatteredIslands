class_name StormElectrocute
extends CardEffect

@export var _base_chance: Array[float]
@export var _base_necrosis_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Electrocute: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]
	var necrosis_amount: float = _base_necrosis_amount[card_lvl - 1]

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.add_card_item(ctx.card_id, storm_stats.on_lightning_callbacks,
		func(target: Entity, _rank: StormCallerManager.Rank, _rank_mult: float) -> void:
			if target == null or not is_instance_valid(target): return
			if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
				ctx.hero.alterations.inflict_condition_stacks(target, necrosis_amount, Alteration.Type.NECROSIS, &"Electrocute")
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.storm_caller.remove_card_items(ctx.card_id)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Electrocute: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_base_chance[cardlvl - 1]) + "% chance to apply " + str(_base_necrosis_amount[cardlvl - 1]) + " necrosis on lightning strike"
