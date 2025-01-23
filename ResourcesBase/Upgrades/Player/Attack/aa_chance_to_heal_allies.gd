extends PlayerUpgrade
class_name AA_ChancetoHeal

@export var aa_heal_allies: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > aa_heal_allies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.heal_ally += aa_heal_allies[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > aa_heal_allies.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(aa_heal_allies[cardlvl-1]) + "% Chance to [color=#FFFF00][wave freq=2.0 amp=5.0]Heal[/wave][/color] allies for 30hp on Attack[/center]"
