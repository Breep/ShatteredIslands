extends PlayerUpgrade

class_name Hp_hp_increase_onmoove

@export var hp_hp_increase_onmoove: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_hp_increase_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_increase_hp_on_moove += hp_hp_increase_onmoove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_hp_increase_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For every 5m , hp max increased by " + str(hp_hp_increase_onmoove[cardlvl - 1]) +"[/center]"
