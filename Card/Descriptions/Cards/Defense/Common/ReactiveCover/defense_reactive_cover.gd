class_name DefenseReactiveCover
extends HeroUpgrade

@export var _base_chance: Array[float]
@export var _base_shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reactive Cover: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.reactive_cover_activated = true
	stats.defense.reactive_cover_chance = _base_chance[cardlvl - 1]
	stats.defense.reactive_cover_shield_amount = _base_shield_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reactive Cover: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "When you take damage, " + str(_base_chance[cardlvl - 1]) + "% chance to gain " + str(_base_shield_amount[cardlvl - 1]) + " shield"
