class_name HpEpicRevive
extends PlayerUpgrade

@export var revive_after_death_percentage_life: int
@export var revive_after_death_percentage_damage: int
@export var revive_after_death_time: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.hp.revive_after_death = true
	stats.hp.revive_after_death_percentage_life = revive_after_death_percentage_life
	stats.hp.revive_after_death_percentage_damage = revive_after_death_percentage_life
	stats.hp.revive_after_death_time = revive_after_death_time


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]When you reach 0 HP, revive after " + str(revive_after_death_time) + \
			"s, " + str(revive_after_death_percentage_life) + "% of your max HP, and deal " + \
			 str(revive_after_death_percentage_damage) + "% of your max HP as " + PlayerUpgrade.PHYSICAL_DAMAGE + "[/center]"
