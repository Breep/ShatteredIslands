extends PlayerUpgrade

class_name Hp_increase_damage

@export var hp_increase_damage: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_increase_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_increase_damage += hp_increase_damage[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_increase_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 200hp, increase physical damage by " + str(hp_increase_damage[cardlvl - 1]) +"[/center]"
