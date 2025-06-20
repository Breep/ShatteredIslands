class_name AttackGatlingGun
extends CharacterUpgrade

@export var _attack_speed_min: Array[int] # % Attack speed minimum
@export var _attack_speed_max: Array[int] # % Attack speed maximum
@export var _duration: float # % Duration to go from minimum to maximum attack speed

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.gatling_gun_activated = true
	stats.auto_attack.gatling_gun_min = _attack_speed_min[cardlvl - 1]
	stats.auto_attack.gatling_gun_max = _attack_speed_max[cardlvl - 1]
	stats.auto_attack.gatling_gun_duration = _duration


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase auto-attack speed from " + str(_attack_speed_min[cardlvl - 1]) + " to " + str(_attack_speed_min[cardlvl - 1]) + \
			" during " + str(_duration) + "s[/center]"
