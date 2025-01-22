extends PlayerUpgrade

class_name Fire_igniteStack_onTimer

@export var fire_igniteStack_ontimer: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_igniteStack_ontimer.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.ignite_stack_timer += fire_igniteStack_ontimer[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_igniteStack_ontimer.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Inflict" + str(fire_igniteStack_ontimer[cardlvl - 1]) + "stack of[color=#FF0000][wave freq=2.0 amp=5.0][hint=1% hp damage/Stack]Ignite[/hint][/wave][/color] every 2sec[/center]"
