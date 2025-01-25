extends PlayerUpgrade

class_name Fire_magic_resist

@export var fire_magic_resist: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_magic_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_magic_resist += fire_magic_resist[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_magic_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(fire_magic_resist[cardlvl - 1]) + "% magic damage reduction[/center]"
