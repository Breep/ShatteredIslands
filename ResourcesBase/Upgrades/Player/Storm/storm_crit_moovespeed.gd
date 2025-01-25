extends PlayerUpgrade

class_name Storm_crit_moovespeed

@export var storm_crit_moovespeed: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > storm_crit_moovespeed.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_crit_moovespeed += storm_crit_moovespeed[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > storm_crit_moovespeed.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Crit increase moove speed by" + str(storm_crit_moovespeed[cardlvl - 1]) + "% for 10sec[/center]"
