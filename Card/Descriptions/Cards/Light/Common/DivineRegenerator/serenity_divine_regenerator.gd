class_name SerenityDivineRegenerator
extends HeroUpgrade

@export var _bonus_duration: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Divine Regenerator: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.divine_regenerator_activated = true
	stats.serenity.divine_regenerator_bonus_duration = _bonus_duration[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"
	
	var d = str(_bonus_duration[cardlvl - 1])
	
	return "Add " + d + "s to all [[REGEN_STACK]] duration."
