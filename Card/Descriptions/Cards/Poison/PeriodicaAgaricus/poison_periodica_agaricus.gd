class_name PoisonPeriodicaAgaricus
extends CharacterUpgrade

@export var _poison_stacks: int = 1
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("PeriodicaAgaricus: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.periodica_agaricus_activated = true
	stats.poison.periodica_agaricus_stacks = _poison_stacks
	stats.poison.periodica_agaricus_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Periodica Agaricus: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Inflict " + str(_poison_stacks) + CharacterUpgrade.POISON + " Stacks, every " + str(_period[cardlvl - 1]) + "[/center]"
