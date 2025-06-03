class_name PoisonPeriodicaAgaricus
extends PlayerUpgrade

@export var _poison_stacks: Array[int]
@export var _period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.periodica_agaricus_activated = true
	stats.poison.periodica_agaricus_stacks = _poison_stacks[cardlvl - 1]
	stats.poison.periodica_agaricus_period = _period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Inflict " + str(_poison_stacks[cardlvl - 1]) + PlayerUpgrade.POISON + " Stacks, every " + str(_period) + "[/center]"
