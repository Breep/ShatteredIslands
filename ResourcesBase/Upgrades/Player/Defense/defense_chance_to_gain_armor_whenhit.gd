class_name DefenseChanceToGainArmorWhenHit
extends PlayerUpgrade

@export var backfire_armor_gain_chance: Array[int]
@export var backfire_armor_gain_stacks: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > backfire_armor_gain_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.backfire_armor_gain_chance = backfire_armor_gain_chance[cardlvl-1]
	stats.defense.backfire_armor_gain_stacks = backfire_armor_gain_stacks


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > backfire_armor_gain_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(backfire_armor_gain_chance[cardlvl - 1]) + "% chance to gain \
			" + str(backfire_armor_gain_stacks) + " stacks of "  + PlayerUpgrade.ARMOR +  \
			" when attacked[/center]"
