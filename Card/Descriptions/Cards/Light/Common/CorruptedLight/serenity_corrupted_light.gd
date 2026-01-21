class_name SerenityCorruptedLight
extends HeroUpgrade

@export var _conversion_percent: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("SerenityCorruptedLight: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.serenity_corrupted_light_activated = true
	stats.serenity.serenity_corrupted_light_conversion_percent = _conversion_percent[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"
	
	var pct = str(_conversion_percent[cardlvl - 1]).pad_decimals(0)
	
	return "Convert " + pct + "% of heal done as [[MAGICAL_DAMAGE]]."
