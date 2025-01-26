class_name PoisonPeriodic
extends PlayerUpgrade

@export var periodic_stacks_number: Array[int]
@export var periodic_stacks_period: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > periodic_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.periodic_stacks_number += periodic_stacks_number[cardlvl - 1]
	player.stats.poison.periodic_stacks_period += periodic_stacks_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > periodic_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Inflict " + str(periodic_stacks_number[cardlvl - 1]) + \
			" Stacks of poison to a random enemy every " + str(periodic_stacks_period) + "[/center]"
