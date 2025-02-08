class_name StormCritMoveSpeed
extends PlayerUpgrade

@export var crit_move_speed_amount: Array[int]
@export var crit_move_speed_duration: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > crit_move_speed_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.crit_move_speed_amount = crit_move_speed_amount[cardlvl-1]
	stats.storm.crit_move_speed_duration = crit_move_speed_duration


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > crit_move_speed_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Crit increase move speed by" + \
			str(crit_move_speed_amount[cardlvl - 1]) + "% for " + \
			str(crit_move_speed_duration) + "s[/center]"
