class_name ColossusBearStrength
extends CharacterUpgrade

@export var _as_reduction: Array[float]
@export var _hp_to_ad_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Bear Strength: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.bear_strength_activated = true
	stats.life.bear_strength_as_reduction = _as_reduction[cardlvl - 1]
	stats.life.bear_strength_hp_to_ad_percent = _hp_to_ad_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Bear Strength: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Decrease attack speed by " + str(_as_reduction[cardlvl - 1]) + "%. Increase AD by " + str(_hp_to_ad_percent[cardlvl - 1]) + "% max HP."
