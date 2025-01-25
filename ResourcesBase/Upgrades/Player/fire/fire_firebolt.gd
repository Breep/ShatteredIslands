extends PlayerUpgrade

class_name Fire_firebolt

@export var fire_fireboltontarget: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_fireboltontarget.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_firebolt += fire_fireboltontarget[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_fireboltontarget.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Send a firebolt every 2sec, that deal" + str(fire_fireboltontarget[cardlvl - 1]) + "% current life of the target[/center]"
