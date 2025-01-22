extends PlayerUpgrade

class_name Defense_ChanceToStaticCharge

@export var ChanceToStaticCharge: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToStaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.static_charge_chance += ChanceToStaticCharge[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToStaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(ChanceToStaticCharge[cardlvl - 1]) + "% Chance to [color=#00008B][wave freq=2.0 amp=5.0][hint=-1% Heal/Stack]Static Charge[/hint][/wave][/color] when being attacked[/center]"
