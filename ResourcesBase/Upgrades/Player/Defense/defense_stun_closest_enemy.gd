extends PlayerUpgrade

class_name Defense_stun_closest_enemy

@export var stun_closest_enemy: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > stun_closest_enemy.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.chance_to_stun_closest_enemy += stun_closest_enemy[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > stun_closest_enemy.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(stun_closest_enemy[cardlvl - 1]) + "% Chance to [color=#8B4513][wave freq=2.0 amp=5.0[hint=Stun 1sec]Stun[/hint]]Stun[/wave][/color] closest  enemy when gain armor[/center]"
