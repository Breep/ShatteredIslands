extends PlayerUpgrade

class_name Defense_armor_onlostHp

@export var gain_armor_on_lost_hp: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > gain_armor_on_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.armor_losthp += gain_armor_on_lost_hp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > gain_armor_on_lost_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Gain [color=#8B4513][wave freq=2.0 amp=5.0][hint=Absorb 1 damage] Armor[/wave][/color] equal to " + str(gain_armor_on_lost_hp[cardlvl - 1]) + "lost hp every 2sec[/center]"
