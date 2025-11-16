class_name PoisonRottingMilk
extends CharacterUpgrade

@export var _chance: Array[float]
@export var _regen_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rotting Milk: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_rotting_milk_activated = true
	stats.poison.poison_rotting_milk_chance = _chance[cardlvl - 1]
	stats.poison.poison_rotting_milk_regen_stacks = _regen_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rotting Milk: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% of chance to gain " + str(_regen_stacks[cardlvl - 1]) + " [[REGEN_STACK]] when applying " \
			+ "[[POISON_STACK]]"
