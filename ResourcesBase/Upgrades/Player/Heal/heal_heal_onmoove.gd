extends PlayerUpgrade

class_name Heal_heal_on_moove

@export var heal_heal_on_moove: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_heal_on_moove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_onmoove += heal_heal_on_moove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_heal_on_moove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Heal ally for" + str(heal_heal_on_moove[cardlvl - 1]) +" every 5m you moove[/center]"
