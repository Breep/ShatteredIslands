extends PlayerUpgrade
class_name AA_ChanceToDoubleAttack

@export var chance_to_double_attack: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_double_attack.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.double_attack_chance += chance_to_double_attack[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_double_attack.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(chance_to_double_attack[cardlvl - 1]) + "% Chance to Double Attack[/center]"
