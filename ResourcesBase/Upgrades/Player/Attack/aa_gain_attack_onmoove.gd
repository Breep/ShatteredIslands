extends PlayerUpgrade
class_name AA_increase_attack_onmoove

@export var increase_attack_onmoove: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > increase_attack_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.attack_onmoove += increase_attack_onmoove[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > increase_attack_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 5 meters moved, increase attack by" + str(increase_attack_onmoove[cardlvl - 1]) + "[/center]"
