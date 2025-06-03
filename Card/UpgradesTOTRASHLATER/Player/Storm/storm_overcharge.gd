class_name StormOvercharge
extends PlayerUpgrade

@export var overcharge_percent: float # % of damage transmited to second target

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.overcharge_activated = true
	stats.storm.overcharge_percent = overcharge_percent


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
		
	return "[center]Each critical strike triggers an electric arc to the nearest enemy,\
	 		dealing " + str(overcharge_percent) + "% of the original damage[/center]"
