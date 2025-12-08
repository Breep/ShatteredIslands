class_name SerenityOverflowingLight
extends CharacterUpgrade

@export var _base_shield_percent: Array[float]

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Overflowing Light: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.overflowing_light_activated = true
	stats.serenity.overflowing_light_shield_percent = _base_shield_percent

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Overflowing Light: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var pct = str(_base_shield_percent[cardlvl - 1]).pad_decimals(0)
	
	return pct + "% overheal convert into shield."
