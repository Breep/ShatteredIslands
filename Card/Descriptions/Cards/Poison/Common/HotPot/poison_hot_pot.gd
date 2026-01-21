class_name PoisonHotPot
extends HeroUpgrade

@export var _chance: Array[float]
@export var _ignite_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Hot Pot: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_hot_pot_activated = true
	stats.poison.poison_hot_pot_chance = _chance[cardlvl - 1]
	stats.poison.poison_hot_pot_ignite_stacks = _ignite_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Hot Pot: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% of chance to gain " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE_STACK]] when applying " \
			+ "[[POISON_STACK]]"
