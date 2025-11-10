class_name ColossusHpShield
extends CharacterUpgrade

@export var _percent: Array[float]
@export var _period: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("HpShield: Wrong cardlvl: ", cardlvl)
		return
	
	


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("HpShield: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return ""
