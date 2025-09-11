class_name AttackDiamondSword
extends CharacterUpgrade

@export var _damage: Array[int] # damage increase

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.diamond_sword_activated = true
	stats.auto_attack.diamond_sword_attack = _damage[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Increase turret damage by " + str(_damage[cardlvl - 1]) + ".[/center]"
