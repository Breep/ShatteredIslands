class_name PoisonCloud
extends PlayerUpgrade

@export var poison_cloud_stacks_number: Array[int]
@export var poison_cloud_stacks_period: float # period of time between aplying each stacks
@export var poison_cloud_range: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_cloud_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_cloud_stacks_number = poison_cloud_stacks_number[cardlvl - 1]
	stats.poison.poison_cloud_stacks_period = poison_cloud_stacks_period
	stats.poison.poison_cloud_range = poison_cloud_range


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_cloud_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Create a poison cloud that inflict " + str(poison_cloud_stacks_number[cardlvl - 1]) \
			 + " stacks of poison to nearby enemies every " + str(poison_cloud_stacks_period) + "sec[/center]"
