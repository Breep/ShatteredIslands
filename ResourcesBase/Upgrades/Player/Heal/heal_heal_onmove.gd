class_name HealOnMove
extends PlayerUpgrade

@export var movement_heal_amount: Array[int]
@export var movement_heal_distance: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.movement_heal_amount = movement_heal_amount[cardlvl-1]
	player.stats.heal.movement_heal_distance = movement_heal_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_heal_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Heal ally for" + str(movement_heal_amount[cardlvl - 1]) + \
	" every " + str(movement_heal_distance) + "m you move[/center]"
