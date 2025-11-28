class_name StormThunderStorm
extends CharacterUpgrade

@export var _duration_bonus: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.LEGENDARY

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Storm: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.thunder_storm_activated = true
	stats.storm.thunder_storm_duration_bonus = _duration_bonus[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Thunder Storm: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Rank S lasts " + str(_duration_bonus[cardlvl - 1]) + "s longer."
