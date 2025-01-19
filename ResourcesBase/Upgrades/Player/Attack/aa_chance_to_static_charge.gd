extends PlayerUpgrade
class_name AA_ChanceToStaticCharge

@export var chance_to_static_charge: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_static_charge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.static_charge_chance += chance_to_static_charge[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_static_charge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(chance_to_static_charge[cardlvl - 1]) + "% Chance to [color=#00008B][wave freq=2.0 amp=5.0]Static Charge[/wave][/color] on Attack[/center]"
