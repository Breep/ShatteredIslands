class_name DefenseOnLostHp
extends PlayerUpgrade

@export var lost_hp_armor_gain_percent: Array[int]
@export var lost_hp_armor_gain_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > lost_hp_armor_gain_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.lost_hp_armor_gain_percent = lost_hp_armor_gain_percent[cardlvl - 1]
	stats.defense.lost_hp_armor_gain_period = lost_hp_armor_gain_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > lost_hp_armor_gain_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain" + PlayerUpgrade.ARMOR + "equal to " + str(lost_hp_armor_gain_percent[cardlvl - 1]) + \
			"% of lost hp every " + str(lost_hp_armor_gain_period) + "s[/center]"
