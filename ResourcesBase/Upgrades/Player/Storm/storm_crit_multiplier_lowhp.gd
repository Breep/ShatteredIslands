extends PlayerUpgrade

class_name Storm_crit_multiplier_onlowhp

@export var storm_crit_multiplier_onlowhp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > storm_crit_multiplier_onlowhp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_crit_multiplier_low_hp += storm_crit_multiplier_onlowhp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > storm_crit_multiplier_onlowhp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For 100hp lost compare to max hp, increase crit dammage by" + str(storm_crit_multiplier_onlowhp[cardlvl - 1]) + "%[/center]"
