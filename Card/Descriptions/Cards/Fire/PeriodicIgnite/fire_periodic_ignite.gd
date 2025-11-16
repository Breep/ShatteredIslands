class_name FirePeriodicIgnite
extends CharacterUpgrade

@export var _ignite_stacks: Array[int]
@export var _period: float

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.periodic_ignite_activated = true
	stats.fire.periodic_ignite_stacks = _ignite_stacks[cardlvl - 1]
	stats.fire.periodic_ignite_period = _period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Inflict " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE_STACK]], every " + str(_period)
