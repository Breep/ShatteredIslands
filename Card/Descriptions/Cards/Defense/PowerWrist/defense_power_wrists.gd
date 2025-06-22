class_name DefensePowerWrists
extends CharacterUpgrade

@export var _armor_stacks: int # Armor stacks needed to increase damage by power_wrist_damage_increase_percent
@export var _damage_increase_percent: Array[int] # % of damage increase for each power_wrist_armor_stacks

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.power_wrists_armor_stacks = _armor_stacks
	stats.defense.power_wrists_damage_increase_percent = _damage_increase_percent[cardlvl - 1]
	stats.defense.power_wrists_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase damage by " + str(_damage_increase_percent[cardlvl - 1]) + "% for each " + str(_armor_stacks) + " " + ARMOR + " lost[/center]"
