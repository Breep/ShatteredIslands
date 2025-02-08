class_name HpIncreaseDamage
extends PlayerUpgrade

@export var damage_increased_by_hp_lost_percentage: Array[int]
@export var damage_increased_by_hp_lost_hp_number: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damage_increased_by_hp_lost_percentage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.hp.damage_increased_by_hp_lost_percentage = damage_increased_by_hp_lost_percentage[cardlvl - 1]
	stats.hp.damage_increased_by_hp_lost_hp_number = damage_increased_by_hp_lost_hp_number


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damage_increased_by_hp_lost_percentage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(damage_increased_by_hp_lost_hp_number) + \
			"hp, increase physical damage by " + \
			str(damage_increased_by_hp_lost_percentage[cardlvl - 1]) + "[/center]"
