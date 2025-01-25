extends PlayerUpgrade

class_name Heal_epic_area

@export var heal_epic_area: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_epic_area.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_epic_area += heal_epic_area[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_epic_area.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Create a lightning heal that pulse every sec and heal allies for " + str(heal_epic_area[cardlvl - 1]) +"%of their max life[/center]"
