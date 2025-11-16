class_name DefenseAdaptativeCloak
extends CharacterUpgrade

@export var _attack_percents: Array[int] # % Percent of AA damage converted into armor stacks

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.adaptative_cloak_attack_percent = _attack_percents[cardlvl - 1]
	stats.defense.adaptative_cloak_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Convert " + str(_attack_percents[cardlvl - 1]) + "% of auto-attack damage into [[SHIELD]] [/center]"
