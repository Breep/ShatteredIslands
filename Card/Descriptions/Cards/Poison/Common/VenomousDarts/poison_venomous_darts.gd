class_name PoisonVenomousDarts
extends CharacterUpgrade

@export var _period: Array[float]
@export var _multiplier: Array[float]
@export var _darts_number: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Venomous Darts: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_venomous_darts_activated = true
	stats.poison.poison_venomous_darts_period = _period[cardlvl - 1]
	stats.poison.poison_venomous_darts_multiplier = _multiplier[cardlvl - 1]
	stats.poison.poison_venomous_darts_darts_number = _darts_number[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Venomous Darts: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + " throw " + str(_darts_number[cardlvl - 1]) + " darts at random enemies.\n" \
			+ "Deals " + str(_multiplier[cardlvl - 1]) + " * [[POISON_STACK]] on target physical damage."
