class_name DefenseDamageReduce
extends PlayerUpgrade

@export var reduce_damage_done: int
@export var reduce_damage_received: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.protector_activated = true
	stats.defense.protector_reduce_damage_done = reduce_damage_done
	stats.defense.protector_reduce_damage_received = reduce_damage_received


func get_description(cardlvl: int) -> String:
	if cardlvl != 1:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(reduce_damage_received) + "% dammage received reduced BUT dammage dealt also reduced by "  \
			+ str(reduce_damage_done) + "%[/center]"
