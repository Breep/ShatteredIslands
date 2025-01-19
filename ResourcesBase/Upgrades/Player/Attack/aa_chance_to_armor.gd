extends PlayerUpgrade
class_name AA_ChanceToArmor

@export var chance_to_stun: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_stun.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.auto_attack.stun_chance += chance_to_stun[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_stun.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(chance_to_stun[cardlvl - 1]) + "% Chance to [color=#8B00FF][wave freq=2.0 amp=5.0]Stun[/wave][/color] on Attack[/center]"
	
