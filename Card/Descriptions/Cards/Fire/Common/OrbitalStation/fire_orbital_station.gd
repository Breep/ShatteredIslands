class_name FireOrbitalStation
extends HeroUpgrade

@export var _crit_chance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Orbital Station: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.orbital_station_activated = true
	stats.fire.orbital_station_crit_chance = _crit_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Orbital Station: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Your [[IGNITE]] applications have " + str(_crit_chance[cardlvl - 1]) + "% chance to crit"
