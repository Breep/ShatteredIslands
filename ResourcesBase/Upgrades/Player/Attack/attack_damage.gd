class_name AttackDamage
extends PlayerUpgrade

@export var damages: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.attack_damage += damages[cardlvl - 1]
	player.stats.auto_attack.attack_damage_boost = damages[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase auto attack damage by " + str(damages[cardlvl - 1]) + "[/center]"
