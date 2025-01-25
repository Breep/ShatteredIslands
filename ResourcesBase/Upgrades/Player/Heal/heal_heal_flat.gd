extends PlayerUpgrade

class_name Heal_heal_flat

@export var heal_flat_sec: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_flat_sec.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_flat += heal_flat_sec[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_flat_sec.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 1.5sec, heal an ally for" + str(heal_flat_sec[cardlvl - 1]) +"[/center]"
