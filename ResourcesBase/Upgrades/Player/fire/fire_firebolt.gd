class_name FireFirebolt
extends PlayerUpgrade

@export var firebolt_damage: Array[float]
@export var firebolt_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > firebolt_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.firebolt_activated = true
	stats.fire.firebolt_damage = firebolt_damage[cardlvl-1]
	stats.fire.firebolt_period = firebolt_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > firebolt_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Send a firebolt every " + str(firebolt_period) + "s, that deals " + \
			str(firebolt_damage[cardlvl - 1]) + "% current life of the target[/center]"
