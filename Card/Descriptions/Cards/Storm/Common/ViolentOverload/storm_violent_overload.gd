class_name StormViolentOverload
extends HeroUpgrade

@export var _base_crit_mult_boost: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Violent Overload: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.violent_overload_activated = true
	stats.storm.violent_overload_crit_mult_boost = _base_crit_mult_boost[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Violent Overload: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increases Crit multiplier by " + str(_base_crit_mult_boost[cardlvl - 1]) + "%"
