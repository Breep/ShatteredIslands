extends PlayerUpgrade

class_name Hp_epic_revive

@export var hp_epic_revive: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_epic_revive.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_epic_revive += hp_epic_revive[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_epic_revive.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]When you reach 0 HP, revive after 3sec, 35% of your max HP, and deal " + str(hp_epic_revive[cardlvl - 1]) +"% of your max health as damage[/center]"
