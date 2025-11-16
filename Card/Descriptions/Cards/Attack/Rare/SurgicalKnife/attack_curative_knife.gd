class_name SurgicalKnife
extends CharacterUpgrade

@export var _chance: Array[float] 
@export var _cleanse_amount: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Surgical Knife: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.surgical_knife_activated = true
	stats.auto_attack.surgical_knife_chance = _chance[cardlvl - 1]
	stats.auto_attack.surgical_knife_cleanse_amount = _cleanse_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Surgical Knife: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% chance to cleanse " + str(_cleanse_amount[cardlvl - 1]) + " self negative stack(s) on attack."
