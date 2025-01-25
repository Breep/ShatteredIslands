extends PlayerUpgrade

class_name Fire_trail_onmoove

@export var fire_trail_onmoove: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_trail_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_trail_onmoove += fire_trail_onmoove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_trail_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]When moving, leave a trail of fire behind. Trail of fire deal " + str(fire_trail_onmoove[cardlvl - 1]) + "hp damage per sec and last 10sec[/center]"
