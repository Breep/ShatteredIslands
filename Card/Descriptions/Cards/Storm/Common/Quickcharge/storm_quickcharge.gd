class_name StormQuickcharge
extends HeroUpgrade

@export var _base_grind_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.quickcharge_activated = true
	stats.storm.quickcharge_grind_percent = _base_grind_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quickcharge: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase rank grind by " + str(_base_grind_percent[cardlvl - 1]) + "%"
