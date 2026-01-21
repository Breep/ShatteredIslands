class_name DefenseAvengersAssemble
extends HeroUpgrade

@export var _crit_chance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.LEGENDARY

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Avengers Assemble: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.avengers_assemble_activated = true
	stats.defense.avengers_assemble_crit_chance = _crit_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Avengers Assemble: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[[SHIELD]] gains have " + str(_crit_chance[cardlvl - 1]) + "% chance to crit"
