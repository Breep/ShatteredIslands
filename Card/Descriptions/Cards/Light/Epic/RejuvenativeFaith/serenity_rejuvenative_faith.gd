class_name SerenityRejuvenativeFaith
extends CharacterUpgrade

@export var _base_chance: Array[float]
@export var _base_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rejuvenative Faith: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.rejuvenative_faith_activated = true
	stats.serenity.rejuvenative_faith_chance = _base_chance[cardlvl - 1]
	stats.serenity.rejuvenative_faith_amount = _base_amount[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rejuvenative Faith: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c = str(_base_chance[cardlvl - 1]).pad_decimals(0)
	var a = str(_base_amount[cardlvl - 1]).pad_decimals(1)
	return c + "% chance to apply " + a + " Regen for each stack dispelled or cleansed."
