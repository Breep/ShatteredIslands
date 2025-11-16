class_name PoisonTideOfCorruption
extends CharacterUpgrade

@export var _multiplier: Array[float]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of corruption: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_tide_of_corruption_activated = true
	stats.poison.poison_tide_of_corruption_multiplier = _multiplier[cardlvl - 1]
	stats.poison.poison_tide_of_corruption_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Tide of corruption: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, inflict " + str(_multiplier[cardlvl - 1]) + "* <enemies alive> [[POISON_STACK]] " \
			+ " to all enemies"
