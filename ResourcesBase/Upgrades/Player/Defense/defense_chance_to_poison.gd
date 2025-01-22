extends PlayerUpgrade

class_name Defense_ChanceToPoison

@export var being_hit_chance_to_poison: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > being_hit_chance_to_poison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.poison_chance += being_hit_chance_to_poison[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > being_hit_chance_to_poison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(being_hit_chance_to_poison[cardlvl - 1]) + "% Chance to [color=#006400][wave freq=2.0 amp=5.0]Poison[/wave][/color] when being attacked[/center]"
