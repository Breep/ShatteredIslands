class_name PoisonResist
extends PlayerUpgrade

@export var poison_resist: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_resist += poison_resist[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(poison_resist[cardlvl - 1]) + " poison resistance[/center]"
