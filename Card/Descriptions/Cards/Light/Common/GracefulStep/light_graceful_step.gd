class_name LightGracefulStep
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _amount_regen: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Graceful Step: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.graceful_step_activated = true
	stats.serenity.graceful_step_increase_dodge = _increase_dodge[cardlvl - 1]
	stats.serenity.graceful_step_regen = _amount_regen[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Graceful Step: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) +". On dodge, Apply" + str(_amount_regen[cardlvl - 1]) + "regen on ally"
