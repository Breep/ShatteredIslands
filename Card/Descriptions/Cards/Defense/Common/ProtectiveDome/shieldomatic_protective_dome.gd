class_name DefenseProtectiveDome
extends CharacterUpgrade

@export var _armor_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protective Dome: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.protective_dome_activated = true
	stats.defense.protective_dome_armor_percent = _armor_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protective Dome: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase [[ARMOR]] by " + str(_armor_percent[cardlvl - 1]) + "% as long as you have at least 1 point of [[SHIELD]]."
