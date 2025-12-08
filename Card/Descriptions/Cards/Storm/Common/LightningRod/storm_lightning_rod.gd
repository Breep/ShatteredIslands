class_name StormLightningRod
extends CharacterUpgrade

@export var _base_threshold: Array[float]
@export var _base_resistance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong cardlvl: ", cardlvl)
		return

	stats.storm.lightning_rod_activated = true
	stats.storm.lightning_rod_hp_threshold_percent = _base_threshold[cardlvl - 1]
	stats.storm.lightning_rod_resistance_amount = _base_resistance[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var t = Utils.format_float(_base_threshold[cardlvl - 1], 0)
	var r = Utils.format_float(_base_resistance[cardlvl - 1], 0)
	return "While above " + t + "% HP, gain " + r + " Critical Resistance."
