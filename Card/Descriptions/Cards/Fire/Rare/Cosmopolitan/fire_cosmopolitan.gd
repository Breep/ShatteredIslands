class_name FireCosmopolitan
extends CharacterUpgrade

@export var _bonus_damage_ratio: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("FireCosmopolitan: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.fire_cosmopolitan_activated = true
	stats.fire.fire_cosmopolitan_bonus_damage_ratio = _bonus_damage_ratio[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"
	
	var ratio = str(_bonus_damage_ratio[cardlvl - 1] * 100.0).pad_decimals(0)
	
	return "Meteor deals " + ratio + "% more damage if it hits only 1 enemy."
