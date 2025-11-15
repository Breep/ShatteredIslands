class_name LightMiracleLight
extends CharacterUpgrade

@export var _crit_chance: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("Miracle Light: Wrong cardlvl: ", cardlvl)
		return
		
	stats.serenity.miracle_light_activated = true
	stats.serenity.mirac =_crit_chance[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("Miracle Light: Wrong cardlvl: ", cardlvl)
		return "ERROR"
		
	return "Your Heals/Cleanse/Regen have " + str(_crit_chance[cardlvl - 1]) + "% * your Crit Chance to crit."
