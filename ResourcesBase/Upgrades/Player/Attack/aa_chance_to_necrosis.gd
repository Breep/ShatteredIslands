extends PlayerUpgrade
class_name AA_ChanceToNecrosis

@export var chance_to_necrosis: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_necrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.necrosis_chance += chance_to_necrosis[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_necrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(chance_to_necrosis[cardlvl-1]) + "% Chance to Necrosis on Attack"
