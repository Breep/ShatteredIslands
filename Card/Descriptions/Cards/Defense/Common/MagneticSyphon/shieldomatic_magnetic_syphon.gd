class_name DefenseMagneticSiphon
extends HeroUpgrade

@export var _period: Array[float]
@export var _steal_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.magnetic_siphon_activated = true
	stats.defense.magnetic_siphon_period = _period[cardlvl - 1]
	stats.defense.magnetic_siphon_steal_percent = _steal_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Magnetic Siphon: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, steal " + str(_steal_percent[cardlvl - 1]) + "% of the highest enemy [[SHIELD]] and convert it into your own."
