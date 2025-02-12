class_name ShadowRegenMove
extends PlayerUpgrade

@export var shadow_shadow_regen_move: Array[int]

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_shadow_regen_move.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.energy_regen += shadow_shadow_regen_move[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_shadow_regen_move.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Increase " + PlayerUpgrade.ENERGY_REGEN + " by " + str(shadow_shadow_regen_move[cardlvl - 1]) +"[/center]"
