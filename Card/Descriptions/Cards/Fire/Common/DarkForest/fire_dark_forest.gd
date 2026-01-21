class_name FireDarkForest
extends HeroUpgrade

@export var _increase_dodge: Array[float] 
@export var _ignite_stacks: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Dark Forest: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.dark_forest_activated = true
	stats.fire.dark_forest_increase_dodge = _increase_dodge[cardlvl - 1]
	stats.fire.dark_forest_ignite_stacks = _ignite_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Dark Forest: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". On dodge, Inflict " + str(_ignite_stacks[cardlvl - 1]) + " [IGNITE STACKS] stack."
