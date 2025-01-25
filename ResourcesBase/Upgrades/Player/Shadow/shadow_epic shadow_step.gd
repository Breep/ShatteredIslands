extends PlayerUpgrade

class_name Shadow_epic_shadow_step

@export var shadow_epic_shadow_step: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_epic_shadow_step.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.shadow_epic_shadow_step += shadow_epic_shadow_step[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_epic_shadow_step.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every " + str(shadow_epic_shadow_step[cardlvl - 1]) +" sec,teleport to the furthest enemy[/center]"
