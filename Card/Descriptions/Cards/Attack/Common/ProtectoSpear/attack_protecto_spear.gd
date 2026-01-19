class_name AttackProtectoSpear
extends HeroUpgrade

@export var _base_chance: Array[float]
@export var _base_shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protecto'Spear: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.protectospear_activated = true
	stats.auto_attack.protectospear_chance = _base_chance[cardlvl - 1]
	stats.auto_attack.protectospear_shield_amount = _base_shield_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protecto'Spear: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_base_chance[cardlvl - 1]) + "% chance to gain " + str(_base_shield_amount[cardlvl - 1]) + " shield on auto-attack"
