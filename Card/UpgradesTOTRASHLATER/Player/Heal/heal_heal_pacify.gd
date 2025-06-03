class_name HealPacify
extends PlayerUpgrade

@export var pacify_enemy_chance: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > pacify_enemy_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.heal.pacify_enemy_activated = true
	stats.heal.pacify_enemy_chance = pacify_enemy_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > pacify_enemy_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]When you " + PlayerUpgrade.HEAL + ", " + str(pacify_enemy_chance[cardlvl - 1]) + \
			"% chance to " + PlayerUpgrade.PACIFY + " a random enemy[/center]"
