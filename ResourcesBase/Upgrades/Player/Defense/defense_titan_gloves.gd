class_name DefenseTitanGloves
extends PlayerUpgrade

@export var _max_health_percents: Array[float] # % of max life converted into armor stacks each tick
@export var _period: float  # Time between 2 ticks

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.titan_gloves_max_health_percent = _max_health_percents[cardlvl]
	stats.defense.titan_gloves_period = _period
	stats.defense.titan_gloves_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain " + ARMOR + " equal to " + str(_max_health_percents[cardlvl]) + "% of self max health every " + str(_period) + "s[/center]"
