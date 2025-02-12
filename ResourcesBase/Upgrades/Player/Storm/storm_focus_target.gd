class_name StormFocusTarget
extends PlayerUpgrade

@export var crit_onfocus_target_min: Array[float]
@export var crit_onfocus_target_max: Array[float]
@export var time_before_activating: int # Time before activating the focus
@export var duration_of_focus:int # Time needed to go from min to max

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > crit_onfocus_target_min.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.focus_target_activated = true
	stats.storm.focus_target_crit_min = crit_onfocus_target_min[cardlvl - 1]
	stats.storm.focus_target_crit_max = crit_onfocus_target_max[cardlvl - 1]
	stats.storm.focus_target_time_before = time_before_activating
	stats.storm.focus_target_duration = duration_of_focus


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > crit_onfocus_target_min.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]While attacking the same target for" + str(time_before_activating) \
			+ " seconds, gain Focus. Focus increases critical hit chance by " \
			+ str(crit_onfocus_target_min[cardlvl - 1]) + "% every second, \
			up to " + str(crit_onfocus_target_max[cardlvl - 1]) + "%[/center]"
