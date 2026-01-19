class_name LightLifeSpring
extends HeroUpgrade

@export var _regen_amount: Array[float]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: 
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Life Spring: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.life_spring_activated = true
	stats.serenity.life_spring_regen_amount = _regen_amount[cardlvl - 1]
	stats.serenity.life_spring_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Life Spring: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Apply " + str(_regen_amount[cardlvl - 1]) + " regen to an ally hero every " + str(_period[cardlvl - 1]) + " sec"
