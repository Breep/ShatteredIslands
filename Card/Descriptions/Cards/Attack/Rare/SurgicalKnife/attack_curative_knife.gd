class_name AttackSurgicalKnife
extends CharacterUpgrade

@export var _chance_percent: int # % of chance to proc
@export var _stacks_number: Array[int] # Number of stacks removed

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl, " [AttackSurgicalKnife]")
		return
	
	stats.auto_attack.surgical_knife_activated = true
	stats.auto_attack.surgical_knife_chance = _chance_percent
	stats.auto_attack.surgical_knife_stacks = _stacks_number[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl, " [AttackSurgicalKnife]")
		return "ERROR"
	
	return "[center]Each turret attack has " + str(_chance_percent) + "% chance to remove" + str(_stacks_number[cardlvl - 1]) + " debuff stacks.[/center]"
