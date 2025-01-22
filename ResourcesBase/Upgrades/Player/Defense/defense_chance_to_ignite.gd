extends PlayerUpgrade

class_name Defense_ChanceToIgnite

@export var being_hit_chance_to_ignite: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > being_hit_chance_to_ignite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.ignite_chance += being_hit_chance_to_ignite[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > being_hit_chance_to_ignite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(being_hit_chance_to_ignite[cardlvl - 1]) + "% Chance to [color=#FF0000][wave freq=2.0 amp=5.0]Ignite[/wave][/color] when being attacked[/center]"
