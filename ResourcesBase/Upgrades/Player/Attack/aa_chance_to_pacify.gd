extends PlayerUpgrade
class_name AA_ChanceToPacify

@export var chance_to_pacify: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_pacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.pacify_chance += chance_to_pacify[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_pacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(chance_to_pacify[cardlvl-1]) + "% Chance to [color=#FFFF00][wave freq=2.0 amp=5.0]Pacify[/wave][/color] on Attack[/center]"
