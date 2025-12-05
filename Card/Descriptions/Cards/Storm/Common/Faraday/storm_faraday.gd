class_name StormFaraday
extends CharacterUpgrade

@export var _base_crit_chance_boost: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Faraday: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.faraday_activated = true
	stats.storm.faraday_crit_chance_boost = _base_crit_chance_boost[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Faraday: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increases Crit Chance by " + str(_base_crit_chance_boost[cardlvl - 1]) + "%"
