class_name AtackSpeedOvertime
extends PlayerUpgrade

@export var attack_speed_overtime_min: Array[int]
@export var attack_speed_overtime_max: Array[int]
@export var attack_speed_overtime_duration: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > attack_speed_overtime_min.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.attack_speed_overtime_min = attack_speed_overtime_min[cardlvl - 1]
	stats.auto_attack.attack_speed_overtime_max = attack_speed_overtime_max[cardlvl - 1]
	stats.auto_attack.attack_speed_overtime_duration = attack_speed_overtime_duration


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > attack_speed_overtime_min.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]For " + str(attack_speed_overtime_duration) + "s, increase auto \
			attack speed by" + str(attack_speed_overtime_min[cardlvl-1]) + \
			"% up to " + str(attack_speed_overtime_max[cardlvl - 1]) + "%[/center]"
