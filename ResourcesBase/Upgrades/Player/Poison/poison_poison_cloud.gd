extends PlayerUpgrade

class_name Poison_poison_cloud

@export var poison_poison_cloud: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_poison_cloud.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.poison_poison_cloud += poison_poison_cloud[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_poison_cloud.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Create a poison cloud that inflict " + str(poison_poison_cloud[cardlvl - 1]) +" stacks of poison to close enemies every 3sec[/center]"
