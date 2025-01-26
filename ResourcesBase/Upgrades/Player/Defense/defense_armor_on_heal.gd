class_name DefenseArmorOnHeal
extends PlayerUpgrade

@export var healing_armor_percent: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_armor_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.healing_armor_percent = healing_armor_percent[cardlvl-1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_armor_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center] Heal apply [color=#8B4513][wave freq=2.0 amp=5.0][hint=Absorb 1 damage] 
			armor[/hint][/wave][/color] to target for" + str(healing_armor_percent[cardlvl - 1]) + \
			"% of the heal amount[/center]"
