extends PlayerUpgrade

class_name Fire_ignite_explosion

@export var fire_ignite_explosion: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_ignite_explosion.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.ignite_explosion += fire_ignite_explosion[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_ignite_explosion.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 50stack of [color=#FF0000][wave freq=2.0 amp=5.0][hint=1% hp damage/Stack]Ignite[/hint][/wave][/color], enmies take " + str(fire_ignite_explosion[cardlvl - 1]) + "% of their max life as damage[/center]"
