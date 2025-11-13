class_name FireNuke
extends CharacterUpgrade

@export var _ignite_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.nuke_activated = true
	stats.fire.nuke_ignite = _ignite_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Nuke: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "At beggining of fight apply " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE_STACK]] to all enemies"
