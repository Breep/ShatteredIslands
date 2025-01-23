extends PlayerUpgrade
class_name AA_attack_Speed_overtime

@export var aa_attackspeed_overtime: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > aa_attackspeed_overtime.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	var speedMultiplier = remap(aa_attackspeed_overtime[cardlvl-1], 0, 100, 1, 2) # Adding 30% is like multiplying by 1.3
	player.stats.auto_attack.attack_speed_overtime *= speedMultiplier


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > aa_attackspeed_overtime.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Increase auto attack speed by" + str(aa_attackspeed_overtime[cardlvl-1]) + "% every sec up to 150%[/center]"
