class_name ColossusAncientGrowth
extends HeroUpgrade

@export var _hp_increase: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Ancient Growth: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.ancient_growth_activated = true
	stats.life.ancient_growth_amount = _hp_increase[cardlvl - 1]
	stats.life.ancient_growth_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Ancient Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase max HP by " + str(_hp_increase[cardlvl - 1]) + " every " + str(_period[0]) + " seconds"
