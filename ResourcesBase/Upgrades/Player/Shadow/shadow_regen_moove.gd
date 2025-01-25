extends PlayerUpgrade

class_name Shadow_shadow_regen_moove

@export var shadow_shadow_regen_moove: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_shadow_regen_moove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.shadow_regen_moove += shadow_shadow_regen_moove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_shadow_regen_moove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Increase moove regen by" + str(shadow_shadow_regen_moove[cardlvl - 1]) +"[/center]"
