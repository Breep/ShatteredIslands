extends PlayerUpgrade
class_name AA_ChanceToPoison

@export var chance_to_poison: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_poison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.poison_chance += chance_to_poison[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_poison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(chance_to_poison[cardlvl - 1]) + "% Chance to Poison on Attack"
