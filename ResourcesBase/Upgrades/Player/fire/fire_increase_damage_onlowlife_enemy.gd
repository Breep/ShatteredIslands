class_name FireDamageIncreaseOnLowLife
extends PlayerUpgrade

@export var damage_increase_on_low_life_enemy_percent: Array[int]
@export var damage_increase_on_low_life_enemy_threshold: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damage_increase_on_low_life_enemy_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.damage_increase_on_low_life_enemy_percent = damage_increase_on_low_life_enemy_percent[cardlvl - 1]
	stats.fire.damage_increase_on_low_life_enemy_threshold = damage_increase_on_low_life_enemy_threshold


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damage_increase_on_low_life_enemy_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Deal" + str(damage_increase_on_low_life_enemy_percent[cardlvl - 1]) + \
			"% more damage to enemies below " + str(damage_increase_on_low_life_enemy_threshold) + \
			"%[/center]"
