class_name SerenityLightCollector
extends CharacterUpgrade

@export var _regen_per_card: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Light Collector: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.light_collector_activated = true
	stats.serenity.light_collector_regen_amount = _regen_per_card[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Light Collector: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var val = str(_regen_per_card[cardlvl - 1]).pad_decimals(1)
	
	return "Apply " + val + " [[REGEN_STACK]] to ALL allies at the start of combat for each unique Light card you possess."
