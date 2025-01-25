extends PlayerUpgrade

class_name Hp_poison_onlosthp

@export var hp_poison_onlosthp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > hp_poison_onlosthp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.hp.hp_poison_onlost_hp += hp_poison_onlosthp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > hp_poison_onlosthp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 1,5sec, for every 100hp lost compare to max hp, inflict " + str(hp_poison_onlosthp[cardlvl - 1]) +" stack of poison to a random enemy[/center]"
