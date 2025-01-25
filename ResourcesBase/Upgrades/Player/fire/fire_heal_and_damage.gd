extends PlayerUpgrade

class_name Fire_heal_and_damage

@export var fire_heal_and_damage: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_heal_and_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_heal_damage_area += fire_heal_and_damage[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_heal_and_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Heal allies and damage enemies in the 2m around for" + str(fire_heal_and_damage[cardlvl - 1]) + "% max life[/center]"
