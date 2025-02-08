class_name DefenseFireArmor
extends PlayerUpgrade

@export var backfire_fire_shield_damage: float
@export var backfire_fire_shield_chance: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > backfire_fire_shield_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.backfire_fire_shield_damage = backfire_fire_shield_damage
	stats.defense.backfire_fire_shield_chance = backfire_fire_shield_chance[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > backfire_fire_shield_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(backfire_fire_shield_chance[cardlvl - 1]) + "% chance to inflict " + \
			str(backfire_fire_shield_damage) + "% of enemy current hp as magic \
			damage when being hit[/center]"
