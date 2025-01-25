extends PlayerUpgrade

class_name Heal_lost_hp

@export var heal_lost_hp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_lost_hp += heal_lost_hp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Heal for" + str(heal_lost_hp[cardlvl - 1]) +"% of your lost health[/center]"
