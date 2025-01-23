extends PlayerUpgrade

class_name Defense_Fire_Armor

@export var damage_fire_armor: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damage_fire_armor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.armor_fire += damage_fire_armor[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damage_fire_armor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(damage_fire_armor[cardlvl - 1]) + "% chance to inflict 0,5% of enemy current hp as magic damage when being hit[/center]"
