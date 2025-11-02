class_name PoisonCorrosion
extends CharacterUpgrade

@export var _buff_stacks: Array[int]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > RARE_CARD_MAX_LEVEL:
		printerr("Corrosion: Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.poison_corrosion_activated = true
	stats.poison.poison_corrosion_buff_stacks = _buff_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > RARE_CARD_MAX_LEVEL:
		printerr("Corrosion: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Each time applying [[POISON_STACK]], remove " + str(_buff_stacks[cardlvl - 1]) + " on the target"
