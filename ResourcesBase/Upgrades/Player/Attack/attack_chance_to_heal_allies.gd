class_name AttackChancetoHeal
extends PlayerUpgrade

@export var healing_attack_chance: Array[int]
@export var healing_attack_heal_amount: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_attack_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.healing_attack_chance = healing_attack_chance[cardlvl - 1]
	stats.auto_attack.healing_attack_heal_amount = healing_attack_heal_amount


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_attack_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(healing_attack_chance[cardlvl-1]) + "% chance to" + PlayerUpgrade.HEAL + " allies for " + \
			str(healing_attack_heal_amount) + " hp on attack[/center]"
