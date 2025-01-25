extends PlayerUpgrade

class_name Defense_armor_onheal

@export var armor_on_heal: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > armor_on_heal.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.pacify_chance += armor_on_heal[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > armor_on_heal.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center] Heal apply [color=#8B4513][wave freq=2.0 amp=5.0][hint=Absorb 1 damage] Armor[/hint][/wave][/color] to target for" + str(armor_on_heal[cardlvl - 1]) + "of the heal amount[/center]"
