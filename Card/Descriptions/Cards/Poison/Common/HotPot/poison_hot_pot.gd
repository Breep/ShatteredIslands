class_name PoisonHotPot
extends CharacterUpgrade

@export var _chance: Array[float]
@export var _poison_stacks: Array[int]
@export var _ignite_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("Hot Pot: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_hot_pot_activated = true
	stats.poison.poison_hot_pot_chance = _chance[cardlvl - 1]
	stats.poison.poison_hot_pot_ignite_stacks = _ignite_stacks[cardlvl - 1]
	stats.poison.poison_hot_pot_poison_stacks = _poison_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("Hot Pot: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% of chance to gain " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE_STACK]] when applying " \
			+ str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]]"
