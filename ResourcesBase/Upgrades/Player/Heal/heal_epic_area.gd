class_name HealEpicArea
extends PlayerUpgrade

@export var heal_area_percentage: int
@export var heal_area_period: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_area_activated = true
	player.stats.heal.heal_area_percentage = heal_area_percentage
	player.stats.heal.heal_area_period = heal_area_period


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center] Heal all allies every " + str(heal_area_period) + " for " \
			+ str(heal_area_percentage) +"% of their max life[/center]"
