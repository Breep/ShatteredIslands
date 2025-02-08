class_name DefenseArmorOnMove
extends PlayerUpgrade

@export var movement_armor_stacks_amount: Array[int]
@export var movement_armor_stacks_distance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > movement_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.gain_armor_stacks_activated = true
	stats.shadow.gain_armor_stacks_value = movement_armor_stacks_amount[cardlvl - 1]
	stats.shadow.gain_armor_stacks_distance = movement_armor_stacks_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > movement_armor_stacks_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Gain" + str(movement_armor_stacks_amount[cardlvl - 1]) + \
			"[color=#8B4513][wave freq=2.0 amp=5.0][hint=Stun 1sec] armor[/hint][/wave][/color] \
			for every " + str(movement_armor_stacks_distance) + "m moved[/center]"
