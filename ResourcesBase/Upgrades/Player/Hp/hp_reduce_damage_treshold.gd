class_name HpDamageReduceBelowThreshold
extends PlayerUpgrade

@export var hp_damage_reduce_below_treshold: Array[int]
@export var damage_taken_reduced_below_treshold_threshold: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_damage_reduce_below_treshold.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	
	stats.hp.damage_taken_reduced_below_treshold_activated = true
	stats.hp.damage_taken_reduced_below_treshold_threshold = hp_damage_reduce_below_treshold[cardlvl - 1]
	stats.hp.damage_taken_reduced_below_treshold_percentage = damage_taken_reduced_below_treshold_threshold


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_damage_reduce_below_treshold.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Reduce damage received below " + \
			str(damage_taken_reduced_below_treshold_threshold) + "% by " + \
			str(hp_damage_reduce_below_treshold[cardlvl - 1]) + "[/center]"
