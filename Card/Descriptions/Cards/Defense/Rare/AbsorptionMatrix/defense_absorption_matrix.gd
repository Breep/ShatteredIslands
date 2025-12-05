class_name DefenseAbsorptionMatrix
extends CharacterUpgrade

@export var _base_chance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Absorption Matrix: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.absorption_matrix_activated = true
	stats.defense.absorption_matrix_chance = _base_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Absorption Matrix: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_base_chance[cardlvl - 1]) + "% chance for shield to not be consumed when received damage"
