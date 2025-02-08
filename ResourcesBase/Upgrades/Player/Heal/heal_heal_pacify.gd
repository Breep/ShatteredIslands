class_name HealPacify
extends PlayerUpgrade

@export var pacify_enemy_attack_number: Array[int]
@export var pacify_enemy_chance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > pacify_enemy_attack_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.heal.pacify_enemy_attack_number = pacify_enemy_attack_number[cardlvl-1]
	stats.heal.pacify_enemy_chance = pacify_enemy_chance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > pacify_enemy_attack_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]After healing an ally, " + str(pacify_enemy_chance) + \
			"% chance to pacify the next " + str(pacify_enemy_attack_number[cardlvl - 1]) + \
			" attack of an enemy[/center]"
