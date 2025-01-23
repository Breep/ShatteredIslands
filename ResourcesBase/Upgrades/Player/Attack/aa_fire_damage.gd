extends PlayerUpgrade
class_name AA_fire_damage

@export var aa_fire_damage_: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > aa_fire_damage_.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.aa_fire_damage += aa_fire_damage_[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > aa_fire_damage_.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 5th attack, deal" + str(aa_fire_damage_[cardlvl - 1]) + "% of the enemy current life[/center]"
