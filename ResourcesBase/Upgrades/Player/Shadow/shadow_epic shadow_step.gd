class_name ShadowEpicShadowStep
extends PlayerUpgrade

@export var shadow_step_period: float # time between 2 shadow steps

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.shadow_step_activated = true
	stats.shadow.shadow_step_period = shadow_step_period


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every " + str(shadow_step_period) + \
			" sec, "  + PlayerUpgrade.TELEPORT + " to the furthest enemy[/center]"
