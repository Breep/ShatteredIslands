class_name DefenseGladiatorHelmet
extends PlayerUpgrade

@export var _armor_stacks: Array[int] # Armor stacks gained every tick
@export var _period: float # Time between 2 ticks

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.gladiator_helmet_period = _period
	stats.defense.gladiator_helmet_armor_stacks = _armor_stacks[cardlvl - 1]
	stats.defense.gladiator_helmet_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(_period) + "s, gain " + str(_armor_stacks[cardlvl - 1]) + " " + ARMOR + "[/center]"
