extends PlayerUpgrade

class_name Storm_overcharge_critic_link

@export var overcharge_critic_link: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > overcharge_critic_link.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.storm.storm_overcharge += overcharge_critic_link[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > overcharge_critic_link.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every critical strike create an electric arc to the closest enemy, dealing" + str(overcharge_critic_link[cardlvl - 1]) + "% damage[/center]"
