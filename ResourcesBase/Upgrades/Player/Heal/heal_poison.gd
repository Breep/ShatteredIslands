class_name HealPoisonOnHeal
extends PlayerUpgrade

@export var poison_stacks_number: Array[int]
@export var poison_stacks_chance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.heal.poison_stacks_number = poison_stacks_number[cardlvl-1]
	stats.heal.poison_stacks_chance 


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_stacks_number.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every time you heal an ally, " + str(poison_stacks_chance) + \
	"% chance to apply " + str(poison_stacks_number[cardlvl - 1]) + \
	" stacks of poison to a random enemy[/center]"
