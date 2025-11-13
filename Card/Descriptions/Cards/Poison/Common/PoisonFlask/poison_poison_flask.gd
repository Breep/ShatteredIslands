class_name PoisonPoisonFlask
extends CharacterUpgrade

@export var _poison_stacks: Array[int]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_flask_activated = true
	stats.poison.poison_flask_stacks = _poison_stacks[cardlvl - 1]
	stats.poison.poison_flask_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Poison Flask: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Inflict " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]], every " + str(_period[cardlvl - 1]) + "s"
