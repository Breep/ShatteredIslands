class_name FireHpDamage
extends PlayerUpgrade

@export var hp_fire_damage: Array[float]
@export var hp_fire_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.hp_fire_damage = hp_fire_damage[cardlvl - 1]
	stats.fire.hp_fire_period = hp_fire_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Deal damage to the target for " + str(hp_fire_damage[cardlvl - 1]) + \
			"% of your max life every " + str(hp_fire_period) + "s[/center]"
