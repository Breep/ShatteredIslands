class_name StormElectrocute
extends HeroUpgrade

@export var _base_chance: Array[float]
@export var _base_necrosis_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Electrocute: Wrong cardlvl: ", cardlvl)
		return
	stats.storm.electrocute_activated = true
	stats.storm.electrocute_chance = _base_chance[cardlvl - 1]
	stats.storm.electrocute_necrosis_amount = _base_necrosis_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Electrocute: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_base_chance[cardlvl - 1]) + "% chance to apply " + str(_base_necrosis_amount[cardlvl - 1]) + " necrosis on lightning strike"
