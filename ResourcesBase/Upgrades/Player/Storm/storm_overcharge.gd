class_name StormOvercharge
extends PlayerUpgrade

@export var overcharge_percent: int # % of damage transmited to second target

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.overcharge_activated = true
	player.stats.storm.overcharge_percent = overcharge_percent


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every critical strike create an electric arc to the closest \
			enemy, dealing" + str(overcharge_percent) + "% of original damage[/center]"
