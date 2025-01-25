extends PlayerUpgrade

class_name Fire_meteor

@export var fire_meteor_onenemies: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_meteor_onenemies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.fire_meteor += fire_meteor_onenemies[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_meteor_onenemies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center] Spawn meteor at enemy position that takes" + str(fire_meteor_onenemies[cardlvl - 1]) + "s to come down. Meteor deal 5% of enemies max hp in 2m area around [/center]"
