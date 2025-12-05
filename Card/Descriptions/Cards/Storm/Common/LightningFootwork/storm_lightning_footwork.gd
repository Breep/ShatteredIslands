class_name StormLightningFootwork
extends CharacterUpgrade

@export var _base_dodge_increase: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Footwork: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.lightning_footwork_activated = true
	stats.storm.lightning_footwork_dodge_increase = _base_dodge_increase[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Footwork: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Each crit increase dodge by " + str(_base_dodge_increase[cardlvl - 1]) + "%. Reset after each dodge"
