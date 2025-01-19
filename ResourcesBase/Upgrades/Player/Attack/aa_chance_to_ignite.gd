extends PlayerUpgrade
class_name AA_ChanceToIgnite

@export var chance_to_ignite: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_ignite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.ignite_chance += chance_to_ignite[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_ignite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(chance_to_ignite[cardlvl - 1]) + "% Chance to [color=#FF0000][wave freq=2.0 amp=5.0]Ignite[/wave][/color] on Attack[/center]"
