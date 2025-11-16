class_name ColossusProteins
extends CharacterUpgrade

@export var _damage_deacrease: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Proteins: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_antidote_activated = true
	stats.poison.poison_antidote_decrease = _damage_deacrease[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Proteins: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Decrease [[POISON_DAMAGE]] received by " + str(_damage_deacrease[cardlvl - 1]) + "%"
