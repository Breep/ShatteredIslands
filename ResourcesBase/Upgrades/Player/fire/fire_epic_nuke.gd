class_name FireEpicNuke
extends PlayerUpgrade

@export var nuke_damage: float
@export var nuke_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.nuke_activated = true
	stats.fire.nuke_damage = nuke_damage
	stats.fire.nuke_period = nuke_period


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]At the start of the fight and every " + str(nuke_period) + "s, \
			land a nuke that deals damage to all enemies for" + str(nuke_damage) + \
			"% of their max life[/center]"
