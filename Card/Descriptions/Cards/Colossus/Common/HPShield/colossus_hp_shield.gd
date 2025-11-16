class_name ColossusHpShield
extends CharacterUpgrade

@export var _percent: Array[float]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("HpShield: Wrong cardlvl: ", cardlvl)
		return
	
	


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("HpShield: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return ""
