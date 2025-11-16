class_name ColossusEvasiveGrowth
extends CharacterUpgrade

@export var _increase_dodge: Array[float] 
@export var _increase_max_hp: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: 
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Evasive Growth: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.evasive_growth_activated = true
	stats.life.evasive_growth_increase_dodge = _increase_dodge[cardlvl - 1]
	stats.life.evasive_growth_increase_max_hp = _increase_max_hp[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Evasive Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". Dodging an attack increase max hp by " + str(_increase_max_hp[cardlvl - 1]) + "."
