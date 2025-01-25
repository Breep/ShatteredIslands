extends PlayerUpgrade

class_name Storm_crit_heal_allies

@export var storm_crit_heal_allies: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > storm_crit_heal_allies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_crit_heal_allies += storm_crit_heal_allies[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > storm_crit_heal_allies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Critical damage heal allies for " + str(storm_crit_heal_allies[cardlvl - 1]) + "% damage dealt[/center]"
