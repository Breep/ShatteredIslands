class_name StormLightningRod
extends CharacterUpgrade

@export var _base_crit_reduction: Array[float]
@export var _base_hp_threshold: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.lightning_rod_activated = true
	stats.storm.lightning_rod_reduction = _base_crit_reduction[cardlvl - 1]
	stats.storm.lightning_rod_hp_threshold = _base_hp_threshold[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Reduce crit damage received by " + str(_base_crit_reduction[cardlvl - 1]) + "% above " + str(_base_hp_threshold[cardlvl - 1]) + "% hp"
