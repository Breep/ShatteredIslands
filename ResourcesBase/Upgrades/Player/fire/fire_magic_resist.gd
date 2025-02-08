class_name FireMagicResist
extends PlayerUpgrade

@export var fire_magic_resist: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_magic_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.magic_resist_percent = fire_magic_resist[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_magic_resist.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(fire_magic_resist[cardlvl - 1]) + "% magic damage reduction[/center]"
