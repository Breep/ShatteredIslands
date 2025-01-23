extends PlayerUpgrade

class_name Defense_Damage_onarmorlost

@export var damage_onarmor_lost: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damage_onarmor_lost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.armor_deal_damage += damage_onarmor_lost[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damage_onarmor_lost.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 1.5s deal damage equal to" + str(damage_onarmor_lost[cardlvl - 1]) + "% total lost armor[/center]"
