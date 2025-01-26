class_name FireEpicNuke
extends PlayerUpgrade

@export var nuke_damage: float
@export var nuke_period: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.nuke_damage = nuke_damage
	player.stats.fire.nuke_period = nuke_period


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]At the start of the fight and every " + str(nuke_period) + "s, \
			land a nuke that deals damage to all enemies for" + str(nuke_damage) + \
			"% of their max life[/center]"
