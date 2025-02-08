class_name HpIncreaseOnMove
extends PlayerUpgrade

@export var hp_increased_on_move_hp: Array[int]
@export var hp_increased_on_move_distance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_increased_on_move_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.gain_max_hp_activated = true
	stats.shadow.gain_max_hp_value = hp_increased_on_move_hp[cardlvl - 1]
	stats.shadow.gain_max_hp_distance = hp_increased_on_move_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_increased_on_move_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]For every " + str(hp_increased_on_move_distance) + \
			"m , hp max increased by " + \
			str(hp_increased_on_move_hp[cardlvl - 1]) +"[/center]"
