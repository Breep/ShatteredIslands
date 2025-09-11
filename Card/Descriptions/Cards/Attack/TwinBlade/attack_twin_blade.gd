class_name AttackTwinBlade
extends CharacterUpgrade

@export var _speed: Array[int] # attack speed increase (in %)

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.twin_blade_activated = true
	stats.auto_attack.twin_blade_speed = _speed[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase turret attack speed by " + str(_speed[cardlvl - 1]) + ".[/center]"
