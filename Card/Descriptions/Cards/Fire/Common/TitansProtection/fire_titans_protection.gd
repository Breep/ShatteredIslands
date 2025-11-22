class_name FireTitansProtection
extends CharacterUpgrade

@export var _hp_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titans Protection: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.titans_protection_activated = true
	stats.fire.titans_protection_hp_amount = _hp_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titans Protection: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase max HP for this battle by " + str(_hp_amount[cardlvl - 1]) + " per [[METEOR]] spawn."
