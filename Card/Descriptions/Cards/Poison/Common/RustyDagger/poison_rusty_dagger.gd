class_name PoisonRustyDagger
extends CharacterUpgrade

@export var _chance: Array[float]
@export var _poison_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rusty Dagger: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_rusty_dagger_activated = true
	stats.poison.poison_rusty_dagger_chance = _chance[cardlvl - 1]
	stats.poison.poison_rusty_dagger_stacks = _poison_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rusty Dagger: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% chance to inflict " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]] when auto attacking"
