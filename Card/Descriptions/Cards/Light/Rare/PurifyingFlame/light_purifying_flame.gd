class_name LightPurifyingFlame
extends CharacterUpgrade

@export var _cleanse_amount: Array[float]
@export var _period: Array[float]
var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Purifying Flame: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.purifying_flame_activated = true
	stats.serenity.purifying_flame_cleanse_amount = _cleanse_amount[cardlvl - 1]
	stats.serenity.purifying_flame_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Purifying Flame: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[0]) + "s, cleanse " + str(_cleanse_amount[cardlvl - 1]) + " negative effects on lowest hp hero ally."
