extends PlayerUpgrade

class_name Storm_criton_focus_target

@export var crit_onfocus_target: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > crit_onfocus_target.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_focus_target += crit_onfocus_target[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > crit_onfocus_target.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]While attacking the same target for 5 seconds, gain Focus. Focus increases critical hit chance by " + str(crit_onfocus_target[cardlvl - 1]) + "% every second, up to 15/30/50%[/center]"
