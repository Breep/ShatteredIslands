class_name DefenseEvadingPants
extends PlayerUpgrade

@export var _armor_stacks: Array[int] # Armor stacks gained each dodge

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.evading_pants_armor_stacks = _armor_stacks[cardlvl]
	stats.defense.mystical_shoulder_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain " + str(_armor_stacks[cardlvl]) + " " + ARMOR + " each dodge[/center]"
