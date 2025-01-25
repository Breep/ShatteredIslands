extends PlayerUpgrade

class_name Poison_poison_onmoove

@export var poison_poison_onmoove: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_poison_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.poison_on_moove += poison_poison_onmoove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_poison_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Inflict " + str(poison_poison_onmoove[cardlvl - 1]) +" stacks of poison for every 5m you moove[/center]"
