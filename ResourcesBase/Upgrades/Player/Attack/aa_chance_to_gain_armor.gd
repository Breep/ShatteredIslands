extends PlayerUpgrade
class_name AA_ChanceToArmor

@export var chance_to_armor: Array[int]

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chance_to_armor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.auto_attack.armor_onattack += chance_to_armor[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chance_to_armor.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]" + str(chance_to_armor[cardlvl - 1]) + "% Chance to gain [color=#8B4513][wave freq=2.0 amp=5.0]Armor[/wave][/color] on Attack[/center]"
	
