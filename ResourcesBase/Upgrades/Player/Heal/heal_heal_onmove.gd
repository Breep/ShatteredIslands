class_name HealOnMove
extends PlayerUpgrade

@export var movement_heal_amount: Array[int]
@export var movement_heal_distance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.heal_ally_activated = true
	stats.shadow.heal_ally_value = movement_heal_amount[cardlvl - 1]
	stats.shadow.heal_ally_distance = movement_heal_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + PlayerUpgrade.HEAL + " for " + str(movement_heal_amount[cardlvl - 1]) + \
			" every " + str(movement_heal_distance) + "m you moved[/center]"
