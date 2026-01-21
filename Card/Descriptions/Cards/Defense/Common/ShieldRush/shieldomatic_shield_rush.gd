class_name DefenseShieldRush
extends HeroUpgrade

@export var _shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Rush: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.shield_rush_activated = true
	stats.defense.shield_rush_amount = _shield_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Rush: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "When battle start, [[SHIELD]] for " + str(_shield_amount[cardlvl - 1])
