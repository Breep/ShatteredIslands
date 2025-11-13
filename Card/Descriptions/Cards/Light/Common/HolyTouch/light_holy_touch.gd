class_name LightHolyTouch
extends CharacterUpgrade

@export var _heal_amount: Array[int]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Holy Touch: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.holy_touch_activated = true
	stats.serenity.holy_touch_amount = _heal_amount[cardlvl - 1]
	stats.serenity.holy_touch_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Holy Touch: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Heals lowest hp ally for " + str(_heal_amount[cardlvl-1]) +" HP every " + str(_period[cardlvl-1]) + " s"
