extends PlayerUpgrade

class_name Storm_poison_oncrit

@export var storm_poison_oncrit: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > storm_poison_oncrit.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_crit_poison += storm_poison_oncrit[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > storm_poison_oncrit.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Critical strike inflict" + str(storm_poison_oncrit[cardlvl - 1]) + "% of damage as poison[/center]"
