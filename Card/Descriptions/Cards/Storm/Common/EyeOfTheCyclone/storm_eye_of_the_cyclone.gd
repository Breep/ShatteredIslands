class_name StormEyeOfTheCyclone
extends CharacterUpgrade

@export var _base_max_hp_percent_bonus: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Eye of the Cyclone: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.eye_of_the_cyclone_activated = true
	stats.storm.eye_of_the_cyclone_max_hp_percent = _base_max_hp_percent_bonus[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Eye of the Cyclone: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "On rank S, gain " + str(_base_max_hp_percent_bonus[cardlvl - 1]) + "% Max HP and heal for the same amount"
