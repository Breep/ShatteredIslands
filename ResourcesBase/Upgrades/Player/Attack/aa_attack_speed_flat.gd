extends PlayerUpgrade
class_name AA_attack_speed_flat

@export var aa_attackspeed_flat: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > aa_attackspeed_flat.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.attack_speed_flat += aa_attackspeed_flat[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > aa_attackspeed_flat.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increased attack speed by " + str(aa_attackspeed_flat[cardlvl - 1]) + "%[/center]"
