class_name HealingCrossbow
extends CharacterUpgrade

@export var _chance: Array[float] 
@export var _heal_amount: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Healing Crossbow: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.healing_crossbow_activated = true
	stats.auto_attack.healing_crossbow_chance = _chance[cardlvl - 1]
	stats.auto_attack.healing_crossbow_heal_amount = _heal_amount[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Healing Crossbow: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% chance to heal for " + str(_heal_amount[cardlvl - 1]) + " on auto-attack."
