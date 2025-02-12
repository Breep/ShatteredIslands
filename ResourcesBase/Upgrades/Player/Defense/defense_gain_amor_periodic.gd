class_name DefenseGainArmorPeriodic
extends PlayerUpgrade

@export var periodic_armor_stacks_amount: Array[int]
@export var periodic_armor_stacks_period: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > periodic_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.periodic_armor_stacks_amount = periodic_armor_stacks_amount[cardlvl-1]
	stats.defense.periodic_armor_stacks_period = periodic_armor_stacks_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > periodic_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain " + str(periodic_armor_stacks_amount[cardlvl - 1]) + " stacks of " + PlayerUpgrade.ARMOR + " every " + \
			str(periodic_armor_stacks_period) + "s[/center]"
