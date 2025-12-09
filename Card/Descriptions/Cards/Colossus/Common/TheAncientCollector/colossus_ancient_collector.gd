class_name ColossusAncientCollector
extends CharacterUpgrade

@export var _amount_per_card: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("The Ancient Collector: Wrong cardlvl: ", cardlvl)
		return
	
	stats.life.ancient_collector_activated = true
	# Flat HP amount to be used in modifier calculation
	stats.life.ancient_collector_amount_per_card = _amount_per_card[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("The Ancient Collector: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var amount_str = str(_amount_per_card[cardlvl - 1]).pad_decimals(0)
	
	return "Gain " + amount_str + " Max Health for each unique Colossus card you have."
