extends PlayerUpgrade

class_name Fire_epic_nuke

@export var epic_nuke: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > epic_nuke.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_epic_nuke += epic_nuke[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > epic_nuke.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]At the start of the fight and every 10sec, land a nuke that deal damage to all enemies for" + str(epic_nuke[cardlvl - 1]) + "% of their max life[/center]"
