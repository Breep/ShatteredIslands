class_name StormHammer
extends CharacterUpgrade

@export var _chance_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.storm_hammer_activated = true
	stats.auto_attack.storm_hammer_chance = _chance_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance_percent[cardlvl - 1]) + "% chance for auto attack to bounce on another target."
