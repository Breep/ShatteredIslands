extends PlayerUpgrade

class_name Fire_Heal_lost_Hp

@export var fire_heal_lost_hp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_heal_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.heal_lost_hp += fire_heal_lost_hp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_heal_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]heal" + str(fire_heal_lost_hp[cardlvl - 1]) + "% lost health every 2sec[/center]"
