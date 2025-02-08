class_name HealPeriodicHeal
extends PlayerUpgrade

@export var periodic_heal_amount: Array[int]
@export var periodic_heal_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > periodic_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.heal.periodic_heal_activated = true
	stats.heal.periodic_heal_amount = periodic_heal_amount[cardlvl-1]
	stats.heal.periodic_heal_period = periodic_heal_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > periodic_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(periodic_heal_period) + "s, heal an ally for" + \
			str(periodic_heal_amount[cardlvl - 1]) + "[/center]"
