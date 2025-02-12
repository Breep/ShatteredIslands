class_name DefenseArmorOnHeal
extends PlayerUpgrade

@export var healing_armor_percent: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_armor_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.healing_armor_activated = true
	stats.defense.healing_armor_percent = healing_armor_percent[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_armor_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + PlayerUpgrade.HEAL + " grants " + PlayerUpgrade.ARMOR + " to target for " + str(healing_armor_percent[cardlvl - 1]) + \
			"% of the heal amount[/center]"
