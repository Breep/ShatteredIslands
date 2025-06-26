class_name AttackHealingCrossbow
extends CharacterUpgrade

@export var _chance: float # % of chance to proc the heal
@export var _percent_heal: Array[float] # % of damage converted as heal

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.healing_crossbow_activated = true
	stats.auto_attack.healing_crossbow_chance = _chance
	stats.auto_attack.healing_crossbow_percent = _percent_heal[cardlvl -1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(_chance) + "% chance to convert " + str(_percent_heal[cardlvl - 1]) + "% auto-attack damage as self heal.[/center]"
