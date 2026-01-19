class_name PoisonShrooms
extends HeroUpgrade

@export var _damage: Array[int]
@export var _life_time: Array[float]
@export var _period: Array[float]
@export var _radius: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Shrooms: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_shrooms_activated = true
	stats.poison.poison_shrooms_damage = _damage[cardlvl - 1]
	stats.poison.poison_shrooms_life_time = _life_time[cardlvl - 1]
	stats.poison.poison_shrooms_period = _period[cardlvl - 1]
	stats.poison.poison_shrooms_radius = _radius[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.EPIC]:
		printerr("Shrooms: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, a shroom grows on a random spot. Shrooms grow for " + str(_life_time[cardlvl - 1]) \
			+ "s. When fully grown, it explodes dealing " + str(_damage[cardlvl - 1]) + "[[POISON_DAMAGE]] in a " \
			+ str(_radius[cardlvl - 1]) + "m radius"
