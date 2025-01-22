extends PlayerUpgrade

class_name Fire_poison_increase_fire_damage

@export var fire_poison_increase_fire_damage: Array[float]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_poison_increase_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.poison_increase_fire_damage += fire_poison_increase_fire_damage[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_poison_increase_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For each stack of [color=#006400][wave freq=2.0 amp=5.0][hint=inflict 1 Dammage over time/stack]Poison[/hint][/wave][/color] increase fire dammage by" + str(fire_poison_increase_fire_damage[cardlvl - 1]) + "%sec[/center]"
