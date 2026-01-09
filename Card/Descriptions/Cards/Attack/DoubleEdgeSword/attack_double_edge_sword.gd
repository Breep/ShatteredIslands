class_name AttackDoubleEdgeSword
extends HeroUpgrade

@export var _damage_percent: Array[int] # % of damage increased when changing target
@export var _attacks_number: Array[int] # Number of attack boosted

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.double_edge_sword_activated = true
	stats.auto_attack.double_edge_sword_damage_percent = _damage_percent[cardlvl - 1]
	stats.auto_attack.double_edge_sword_attacks_number = _attacks_number[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]When switching target, the next " + str(_attacks_number[cardlvl - 1]) + " attacks deal " + \
			str(_damage_percent[cardlvl - 1]) + " % more damage[/center]"
