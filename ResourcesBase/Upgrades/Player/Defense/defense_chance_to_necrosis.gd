extends PlayerUpgrade

class_name Defense_ChanceToNecrosis

@export var being_hit_ChanceToNecrosis: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > being_hit_ChanceToNecrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.necrosis_chance += being_hit_ChanceToNecrosis[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > being_hit_ChanceToNecrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(being_hit_ChanceToNecrosis[cardlvl - 1]) + "% Chance to [color=#8B00FF][wave freq=2.0 amp=5.0][hint=-1% Heal/Stack]Necrosis[/hint][/wave][/color] when being attacked[/center]"
