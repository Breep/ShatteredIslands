class_name ShadowInvincible
extends PlayerUpgrade

@export var distance_to_activate: int # distance needed for activation
@export var invincibility_time: Array[float]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > invincibility_time.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.invincibility_time += invincibility_time[cardlvl-1]
	player.stats.shadow.distance_for_invincibility = distance_to_activate


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > invincibility_time.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]After moving " + str(distance_to_activate) + \
			"5m, you are invincible for " + \
			str(invincibility_time[cardlvl - 1]) + " sec. Stackable[/center]"
