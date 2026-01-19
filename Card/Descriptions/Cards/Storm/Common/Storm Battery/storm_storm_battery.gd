class_name StormStormBattery
extends HeroUpgrade

@export var _base_mana_gain: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Battery: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.storm_battery_activated = true
	stats.storm.storm_battery_mana_gain = _base_mana_gain[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Battery: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Each Lightning cast generates " + str(_base_mana_gain[cardlvl - 1]) + " * (Rank Value) mana"
