class_name StormStormBreaker
extends CharacterUpgrade

@export var _base_reduction_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Breaker: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.storm_breaker_activated = true
	stats.storm.storm_breaker_base_reduction_percent = _base_reduction_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Breaker: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Each [[RANK]] grind applies " + str(_base_reduction_percent[cardlvl - 1]) + "% * Rank Value [[VULNERABILITY]] to target."
