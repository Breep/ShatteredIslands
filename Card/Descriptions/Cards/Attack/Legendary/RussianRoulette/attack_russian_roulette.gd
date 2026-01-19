class_name AttackRussianRoulette
extends HeroUpgrade

@export var _min_percent: Array[int]
@export var _max_percent: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("AttackRussianRoulette: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.attack_russian_roulette_activated = true
	stats.auto_attack.attack_russian_roulette_min_percent = _min_percent[cardlvl - 1]
	stats.auto_attack.attack_russian_roulette_max_percent = _max_percent[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"
	
	var min_p = str(_min_percent[cardlvl - 1]).pad_decimals(0)
	var max_p = str(_max_percent[cardlvl - 1]).pad_decimals(0)
	
	return "Auto Attack deals between " + min_p + " - " + max_p + "% damage."
