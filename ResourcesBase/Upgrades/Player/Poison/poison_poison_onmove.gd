class_name PoisonMovementPoison
extends PlayerUpgrade

@export var movement_stacks_number: Array[int]
@export var movement_stacks_distance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.inflict_poison_stacks_activated = true
	stats.shadow.inflict_poison_stacks_value = movement_stacks_number[cardlvl - 1]
	stats.shadow.inflict_poison_stacks_distance = movement_stacks_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Inflict " + str(movement_stacks_number[cardlvl - 1]) \
	 + PlayerUpgrade.POISON + " stacks, for every" + str(movement_stacks_distance) + "m moved[/center]"
