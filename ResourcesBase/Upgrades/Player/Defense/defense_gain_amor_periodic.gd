class_name DefenseGainArmorPeriodic
extends PlayerUpgrade

@export var periodic_armor_stacks_amount: Array[int]
@export var periodic_armor_stacks_period: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > periodic_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.periodic_armor_stacks_amount = periodic_armor_stacks_amount[cardlvl-1]
	player.stats.defense.periodic_armor_stacks_period = periodic_armor_stacks_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > periodic_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain" + str(periodic_armor_stacks_amount[cardlvl - 1]) + " [color=#8B4513]\
			[wave freq=2.0 amp=5.0[hint=Absorb 1 damage][hint] armor[/wave][/color] every " + \
			str(periodic_armor_stacks_period) + "s.[/center]"
