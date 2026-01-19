class_name SerenityRadiantOverflow
extends HeroUpgrade

@export var _ratio: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("SerenityRadiantOverflow: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.serenity_radiant_overflow_activated = true
	stats.serenity.serenity_radiant_overflow_ratio = _ratio[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"
	
	var r = str(_ratio[cardlvl - 1] * 100.0).pad_decimals(1)
	
	return "Heals are " + r + "% more effective for each [[REGEN_STACK]] on target."
