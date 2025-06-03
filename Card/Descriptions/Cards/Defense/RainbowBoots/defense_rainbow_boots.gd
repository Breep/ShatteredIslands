class_name DefenseRainbowBoots
extends PlayerUpgrade

@export var _armor_stacks: Array[int] # Armor stacks lost needed to proc rainbow_boots effect

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.rainbow_boots_armor_stacks = _armor_stacks[cardlvl - 1]
	stats.defense.rainbow_boots_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(_armor_stacks[cardlvl - 1]) + " " + ARMOR + " lost, inflict 1 status effect to a random enemy[/center]"
