class_name DefenseSmithHammer
extends CharacterUpgrade

@export var _armor_stacks: int # Armor stacks gained when effect proc
@export var _chance_percents: Array[int]  # % of chance to proc effect when being hit

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.smith_hammer_chance_percent = _chance_percents[cardlvl - 1]
	stats.defense.smith_hammer_armor_stacks = _armor_stacks
	stats.defense.smith_hammer_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(_chance_percents[cardlvl - 1]) + "% of chance to gain " + str(_armor_stacks) + ARMOR + " when being hit[/center]"
