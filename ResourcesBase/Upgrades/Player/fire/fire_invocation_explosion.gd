extends PlayerUpgrade

class_name Fire_invocation_explosion

@export var fire_invocation_explosion: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_invocation_explosion.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.invocation_explosion += fire_invocation_explosion[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_invocation_explosion.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Invocation explode on death and deal" + str(fire_invocation_explosion[cardlvl - 1]) + "% of their max life to close enemies [/center]"
