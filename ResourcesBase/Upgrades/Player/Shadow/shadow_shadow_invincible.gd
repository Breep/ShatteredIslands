class_name ShadowInvincible
extends PlayerUpgrade

@export var distance_to_activate: int # distance needed for activation
@export var invincibility_time: Array[float]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > invincibility_time.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.untargetable_activated = true
	stats.shadow.untargetable_time += invincibility_time[cardlvl - 1]
	stats.shadow.untargetable_distance = distance_to_activate


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > invincibility_time.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]After moving " + str(distance_to_activate) + \
			"m, you are invincible for " + \
			str(invincibility_time[cardlvl - 1]) + "s. Stackable[/center]"
