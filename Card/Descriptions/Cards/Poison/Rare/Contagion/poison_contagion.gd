class_name PoisonContagion
extends CharacterUpgrade

@export var _percent: Array[float]
@export var _radius: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Contagion: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_contagion_activated = true
	stats.poison.poison_contagion_percent = _percent[cardlvl - 1]
	stats.poison.poison_contagion_radius = _radius[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Contagion: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "When an enemy dies, it speads " + str(_percent[cardlvl - 1]) + "% of its [[POISON_STACK]] to nearby enemies in a " \
			+ str(_radius[cardlvl - 1]) + "m radius"
