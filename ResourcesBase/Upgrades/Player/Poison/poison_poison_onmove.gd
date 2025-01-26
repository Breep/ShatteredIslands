class_name PoisonMovementPoison
extends PlayerUpgrade

@export var movement_stacks_number: Array[int]
@export var movement_stacks_distance: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.movement_stacks_number = movement_stacks_number[cardlvl - 1]
	player.stats.poison.movement_stacks_distance = movement_stacks_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Inflict " + str(movement_stacks_number[cardlvl - 1]) + \
	" stacks of poison for every" + str(movement_stacks_distance) + "m you move[/center]"
