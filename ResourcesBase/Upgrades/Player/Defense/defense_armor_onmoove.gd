extends PlayerUpgrade

class_name Defense_armor_onmoove

@export var gain_armor_onmoove: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > gain_armor_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.armor_gainstack_onmoove += gain_armor_onmoove[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > gain_armor_onmoove.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Gain" + str(gain_armor_onmoove[cardlvl - 1]) + "[color=#8B4513][wave freq=2.0 amp=5.0[hint=Stun 1sec]Armor[/hint]]armor[/wave][/color] for every 5m moved[/center]"
