class_name ColossusProteins
extends HeroUpgrade

@export var _max_hp_increase: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Proteins: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.proteins_activated = true
	stats.life.proteins_max_hp_increase = _max_hp_increase[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Proteins: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase max HP by " + str(_max_hp_increase[cardlvl - 1])
