class_name AttackSpeed
extends PlayerUpgrade

@export var attack_speed_boost: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > attack_speed_boost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.attack_speed_boost += attack_speed_boost[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > attack_speed_boost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increased attack speed by " + str(attack_speed_boost[cardlvl - 1]) + "%[/center]"
