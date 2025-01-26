class_name AttackChancetoHeal
extends PlayerUpgrade

@export var healing_attack_chance: Array[int]
@export var healing_attack_heal_amount: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_attack_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.healing_attack_chance = healing_attack_chance[cardlvl - 1]
	player.stats.auto_attack.healing_attack_heal_amount = healing_attack_heal_amount


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_attack_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(healing_attack_chance[cardlvl-1]) + "% of chance to [color=#FFFF00]\
			[wave freq=2.0 amp=5.0]heal[/wave][/color] allies for " + \
			str(healing_attack_heal_amount) + " hp on Attack[/center]"
