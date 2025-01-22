extends PlayerUpgrade

class_name Fire_ignite_StaticCharge

@export var fire_ignite_and_StaticCharge: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_ignite_and_StaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.ignite_static_charge += fire_ignite_and_StaticCharge[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_ignite_and_StaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every" + str(fire_ignite_and_StaticCharge[cardlvl - 1]) + "sec, lanch a magic attack that bounce against the first enemy and apply [color=#FF0000][wave freq=2.0 amp=5.0][hint=1% hp damage/Stack]Ignite[/hint][/wave][/color] AND [color=#00008B][wave freq=2.0 amp=5.0][hint=-1% Heal/Stack]Static Charge[/hint][/wave][/color][/center]"
