class_name ShadowEpicShadowStep
extends PlayerUpgrade

@export var shadow_step_period: int # time between 2 shadow steps

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.shadow_step_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every " + str(shadow_step_period) + \
			" sec, teleport to the furthest enemy[/center]"
