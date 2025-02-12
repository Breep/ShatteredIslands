class_name StormCritMultiplierOnLostHp
extends PlayerUpgrade

@export var lost_hp_crit_multiplier_amount: Array[int]
@export var lost_hp_crit_multiplier_hp_number: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > lost_hp_crit_multiplier_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.lost_hp_crit_multiplier_activated = true
	stats.storm.lost_hp_crit_multiplier_amount = lost_hp_crit_multiplier_amount[cardlvl - 1]
	stats.storm.lost_hp_crit_multiplier_hp_number = lost_hp_crit_multiplier_hp_number


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > lost_hp_crit_multiplier_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]For each " + str(lost_hp_crit_multiplier_hp_number) + \
			"HP lost, increase " + PlayerUpgrade.CRITICAL_MULTIPLIER + " by" + \
			str(lost_hp_crit_multiplier_amount[cardlvl - 1]) + "%[/center]"
