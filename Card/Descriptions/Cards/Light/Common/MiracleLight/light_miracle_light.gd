class_name MiracleLight
extends HeroUpgrade

@export var _crit_chance_percent: Array[float] 
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Miracle Light: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.miracle_light_activated = true
	stats.serenity.miracle_light_crit_chance = _crit_chance_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Miracle Light: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Your Heals/Cleanse/Regen have " + str(_crit_chance_percent[cardlvl - 1]) + "% Chance to crit."
