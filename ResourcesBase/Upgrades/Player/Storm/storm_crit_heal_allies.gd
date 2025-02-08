class_name StormCritHealAllies
extends PlayerUpgrade

@export var healing_crit_amount: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_crit_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.healing_crit_amount = healing_crit_amount[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_crit_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Critical damage heal allies for " + \
			str(healing_crit_amount[cardlvl - 1]) + "% damage dealt[/center]"
