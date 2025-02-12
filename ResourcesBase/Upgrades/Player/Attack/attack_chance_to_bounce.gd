class_name AttackChanceToBounce
extends PlayerUpgrade

@export var chance_to_bounce: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.bounce_chance += chance_to_bounce


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(chance_to_bounce) + "% chance for auto \
			attack projectile to "+ PlayerUpgrade.BOUNCE +" on an second target[/center]"
