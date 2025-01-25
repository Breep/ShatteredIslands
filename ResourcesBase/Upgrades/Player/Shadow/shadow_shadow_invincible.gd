extends PlayerUpgrade

class_name Shadow_shadow_invincible

@export var shadow_shadow_invincible: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_shadow_invincible.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.shadow_invincible_onmoove += shadow_shadow_invincible[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_shadow_invincible.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]After moving 5m, you are invincible for " + str(shadow_shadow_invincible[cardlvl - 1]) +" sec. Stackable[/center]"
