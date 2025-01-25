extends PlayerUpgrade

class_name Fire_damage_onyour_maxhp

@export var fire_damage_onyour_maxhp: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_damage_onyour_maxhp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_damage_onmaxhp += fire_damage_onyour_maxhp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_damage_onyour_maxhp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Deal damage to the target for " + str(fire_damage_onyour_maxhp[cardlvl - 1]) + "% of your max life every 2sec[/center]"
