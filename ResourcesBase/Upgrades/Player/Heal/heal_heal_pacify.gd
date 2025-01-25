extends PlayerUpgrade

class_name Heal_pacify

@export var heal_pacify: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_pacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_pacify += heal_pacify[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_pacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]After healing an ally, pacify the next " + str(heal_pacify[cardlvl - 1]) +" attack of an enemy[/center]"
