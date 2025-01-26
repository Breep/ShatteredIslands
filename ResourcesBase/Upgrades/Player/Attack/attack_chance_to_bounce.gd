class_name AttackChanceToBounce
extends PlayerUpgrade

@export var chance_to_bounce: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.bounce_chance += chance_to_bounce


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(chance_to_bounce) + "% of chance for auto \
			attack projectile to bounce on an second target[/center]"
