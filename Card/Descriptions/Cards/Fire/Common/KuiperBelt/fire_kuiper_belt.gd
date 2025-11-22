class_name FireKuiperBelt
extends CharacterUpgrade

@export var _shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.kuiper_belt_activated = true
	stats.fire.kuiper_belt_shield_amount = _shield_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Gain " + str(_shield_amount[cardlvl - 1]) + " [[SHIELD]] per [[METEOR]] spawn"
