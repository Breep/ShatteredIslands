class_name StormQuickcharge
extends CharacterUpgrade

@export var _base_duration_bonus: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.quickcharge_activated = true
	stats.storm.quickcharge_duration_bonus = _base_duration_bonus[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase Rank S duration by " + str(_base_duration_bonus[cardlvl - 1]) + " sec"
