extends PlayerUpgrade

class_name Poison_poison_flat

@export var poison_poison_flat: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_poison_flat.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.poison_poison_flat += poison_poison_flat[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_poison_flat.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Inflict " + str(poison_poison_flat[cardlvl - 1]) +" Stacks of poison to a random enemy every 2sec[/center]"
