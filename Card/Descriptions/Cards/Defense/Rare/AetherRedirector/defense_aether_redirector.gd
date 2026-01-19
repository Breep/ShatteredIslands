class_name DefenseAetherRedirector
extends HeroUpgrade

@export var _base_period: Array[float]
@export var _base_shield: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.aether_redirector_activated = true
	stats.defense.aether_redirector_period = _base_period[cardlvl - 1]
	stats.defense.aether_redirector_shield_amount = _base_shield[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aether Redirector: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_base_period[cardlvl - 1]) + "s, redirect the next single-target attack taken by an ally to yourself and gain " + str(_base_shield[cardlvl - 1]) + " shield"
