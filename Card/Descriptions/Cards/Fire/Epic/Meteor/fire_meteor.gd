class_name FireMeteor
extends CharacterUpgrade

@export var _period: float
@export var _ignite_stacks: Array[int]
@export var _damage_per_stack: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl, " - ", get_class())
		return
	
	stats.fire.meteor_activated = true
	stats.fire.meteor_ignite_stacks = _ignite_stacks[cardlvl - 1]
	stats.fire.meteor_damage_per_stack = _damage_per_stack[cardlvl - 1]
	stats.fire.meteor_period = _period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl, " - ", get_class())
		return "ERROR"
	
	return ""
