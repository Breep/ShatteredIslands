class_name AttackStormHammer
extends PlayerUpgrade

@export var _bounce_chance: int # % Percent of chance for auto attack to bounce

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.storm_hammer_activated = true
	stats.auto_attack.storm_hammer_chance = _bounce_chance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Auto-attack have " + str(_bounce_chance) + "% of to bounce[/center]"
