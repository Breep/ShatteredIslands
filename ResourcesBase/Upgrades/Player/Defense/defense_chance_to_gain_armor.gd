extends PlayerUpgrade

class_name Defense_ChanceToGainArmor

@export var being_hit_ChanceToGainArmor: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > being_hit_ChanceToGainArmor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.defense.chance_to_gain_armor += being_hit_ChanceToGainArmor[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > being_hit_ChanceToGainArmor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(being_hit_ChanceToGainArmor[cardlvl - 1]) + "% Chance to gain [color=#8B4513][wave freq=2.0 amp=5.0[hint=Absorb 1 damage]armor[/hint]]Stun[/wave][/color] when being attacked[/center]"
