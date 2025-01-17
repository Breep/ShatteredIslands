extends PlayerUpgrade
class_name AA_ChanceToBounce

@export var chance_to_bounce: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_bounce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.bounce_chance += chance_to_bounce[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_bounce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(chance_to_bounce[cardlvl - 1]) + "% Chance for auto attack projectile to bounce on an other target"
