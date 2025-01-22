extends PlayerUpgrade

class_name Defense_gain_amor

@export var gain_armor_sec: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > gain_armor_sec.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.gain_armor += gain_armor_sec[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > gain_armor_sec.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Gain" + str(gain_armor_sec[cardlvl - 1]) + " [color=#8B4513][wave freq=2.0 amp=5.0]Armor[/wave][/color] /sec[/center]"
