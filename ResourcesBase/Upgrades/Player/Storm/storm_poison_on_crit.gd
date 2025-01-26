class_name StormPoisonOnCrit
extends PlayerUpgrade

@export var crit_poison_amount: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > crit_poison_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.crit_poison_amount += crit_poison_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > crit_poison_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Critical strike inflict" + str(crit_poison_amount[cardlvl - 1]) + \
			"% of damage as poison[/center]"
