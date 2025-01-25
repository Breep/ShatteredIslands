extends PlayerUpgrade

class_name Hp_increase_hp

@export var hp_increase_hp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_increase_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_increase_hp += hp_increase_hp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_increase_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Increase max Hp by " + str(hp_increase_hp[cardlvl - 1]) +"[/center]"
