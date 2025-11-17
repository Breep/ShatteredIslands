class_name ColossusCrystalMountain
extends CharacterUpgrade

@export var _defense_increase: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.crystal_mountain_activated = true
	stats.life.crystal_mountain_defense_increase = _defense_increase[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Crystal Mountain: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase defense (Physical, Magical, Poison resist) by " + str(_defense_increase[cardlvl - 1])
