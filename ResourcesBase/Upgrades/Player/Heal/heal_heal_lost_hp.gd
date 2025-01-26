class_name HealLostHp
extends PlayerUpgrade

@export var lost_hp_regen_percentage: Array[int]
@export var lost_hp_regen_period: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > lost_hp_regen_percentage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.lost_hp_regen_percentage = lost_hp_regen_percentage[cardlvl-1]
	player.stats.heal.lost_hp_regen_period 


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > lost_hp_regen_percentage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Self heal for " + str(lost_hp_regen_percentage[cardlvl - 1]) + \
			"% of your lost health every " + str(lost_hp_regen_period) + "[/center]"
