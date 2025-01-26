class_name PoisonEpicMultiplyDamage
extends PlayerUpgrade

@export var multiply_damage: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.multiply_damage = multiply_damage


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Multiply poison damage by " + str(multiply_damage) +"[/center]"
