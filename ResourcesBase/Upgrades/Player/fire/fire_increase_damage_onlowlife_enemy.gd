extends PlayerUpgrade

class_name Fire_damage_increase_on_low_life_enemy

@export var fire_damage_increase_on_low_life_enemy: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_damage_increase_on_low_life_enemy.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.damage_increase_on_low_life_enemy += fire_damage_increase_on_low_life_enemy[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_damage_increase_on_low_life_enemy.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Deal" + str(fire_damage_increase_on_low_life_enemy[cardlvl - 1]) + "% more damage to enemies below 50%[/center]"
