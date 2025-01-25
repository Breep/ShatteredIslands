extends PlayerUpgrade

class_name Hp_damage_reduce_below_treshold

@export var hp_damage_reduce_below_treshold: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_damage_reduce_below_treshold.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_reduce_damage_below_treshold += hp_damage_reduce_below_treshold[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_damage_reduce_below_treshold.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Reduce damage received below 35% by " + str(hp_damage_reduce_below_treshold[cardlvl - 1]) +"[/center]"
