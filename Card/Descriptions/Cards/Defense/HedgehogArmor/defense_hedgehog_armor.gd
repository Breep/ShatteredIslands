class_name DefenseHedgehogArmor
extends CharacterUpgrade

@export var _period: float # Time between two ticks
@export var _lost_armor_percentages: Array[int] # Percent of armor lost dealed as damage

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.hedgehog_armor_period = _period
	stats.defense.hedgehog_armor_lost_armor_percent = _lost_armor_percentages[cardlvl - 1]
	stats.defense.hedgehog_armor_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(_period) + "s, convert " + str(_lost_armor_percentages[cardlvl - 1]) + "% of " + ARMOR + " lost[/center]"
