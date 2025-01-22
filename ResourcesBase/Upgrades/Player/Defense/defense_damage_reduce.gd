extends PlayerUpgrade

class_name Defense_DamageReduce

@export var Damage_received_Reduce: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Damage_received_Reduce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.reduce_damage_received += Damage_received_Reduce[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Damage_received_Reduce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(Damage_received_Reduce[cardlvl - 1]) + "-20% dammage deal reduced BUT 30% dammage received reduced[/center]"
