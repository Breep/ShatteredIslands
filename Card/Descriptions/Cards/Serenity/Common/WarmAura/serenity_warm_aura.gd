class_name SerenityWarmAura
extends CharacterUpgrade

@export var _base_chance: Array[float]
@export var _base_cleanse_amount: Array[float]

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Warm Aura: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.warm_aura_activated = true
	stats.serenity.warm_aura_chance = _base_chance
	stats.serenity.warm_aura_cleanse_amount = _base_cleanse_amount

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Warm Aura: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c = Utils.format_float(_base_chance[cardlvl - 1], 0)
	var a = Utils.format_float(_base_cleanse_amount[cardlvl - 1], 0)
	
	return "On heal, " + c + "% chance to cleanse " + a + " on target."
