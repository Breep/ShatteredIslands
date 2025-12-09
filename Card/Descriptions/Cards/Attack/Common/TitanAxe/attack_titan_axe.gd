class_name AttackTitanAxe
extends CharacterUpgrade

@export var _attack_number: int # Attack number needed to proc the damage buff
@export var _damage_percent: Array[float] # Damage buff in % of target hp max

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.titan_axe_activated = true
	stats.auto_attack.titan_axe_attack_number = _attack_number
	stats.auto_attack.titan_axe_damage_percent = _damage_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(_attack_number) + " attacks, increase damage by " + str(_damage_percent[cardlvl - 1]) + "% of target max HP [/center]"
