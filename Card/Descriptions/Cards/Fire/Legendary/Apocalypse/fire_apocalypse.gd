class_name FireApocalypse
extends CharacterUpgrade

@export var _damage_ratio: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("FireApocalypse: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.fire_apocalypse_activated = true
	stats.fire.fire_apocalypse_damage_ratio = _damage_ratio[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"
	
	var ratio = str(_damage_ratio[cardlvl - 1])
	
	return "Meteors deal bonus magic damage equal to +" + ratio + " * target's current Ignite stacks."
