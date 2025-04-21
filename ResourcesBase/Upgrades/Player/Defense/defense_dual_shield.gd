class_name DefenseDualShield
extends PlayerUpgrade

@export var _health_threshold: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.dual_shield_health_threshold = _health_threshold
	stats.defense.dual_shield_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Double" + ARMOR + " gained while above " + str(_health_threshold) + "% hp[/center]"
