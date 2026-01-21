class_name TwinBlade
extends HeroUpgrade

@export var _attack_speed_percent: Array[float] 

func apply(stats: FamiliesStats, cardlvl: int) -> void: 
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Twin Blade: Wrong cardlvl: ", cardlvl)
		return
	
	# On utilise stats.auto_attack comme tu l'as demandé
	stats.auto_attack.twin_blade_activated = true
	stats.auto_attack.twin_blade_speed = _attack_speed_percent[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Twin Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase attack speed by " + str(_attack_speed_percent[cardlvl - 1]) + "%."
