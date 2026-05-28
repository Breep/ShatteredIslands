class_name StormThunderStorm
extends CardEffect

@export var _duration_bonus: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Storm: Wrong card_lvl: ", card_lvl)
		return

	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.thunder_storm_duration_bonus = _duration_bonus[card_lvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Storm: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Rank S lasts " + str(_duration_bonus[cardlvl - 1]) + "s longer."
