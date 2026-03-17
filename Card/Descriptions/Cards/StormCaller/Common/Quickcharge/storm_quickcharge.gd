class_name StormQuickcharge
extends HeroUpgrade

@export var _base_grind_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong card_lvl: ", card_lvl)
		return

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.quickcharge_grind_percent = _base_grind_percent[card_lvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase rank grind by " + str(_base_grind_percent[cardlvl - 1]) + "%"
