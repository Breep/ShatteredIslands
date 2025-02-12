class_name DefenseChanceToPoison
extends PlayerUpgrade

@export var backfire_poison_chance: Array[int]
@export var backfire_poison_stacks: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > backfire_poison_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.backfire_poison_chance = backfire_poison_chance[cardlvl - 1]
	stats.defense.backfire_poison_stacks = backfire_poison_stacks 


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > backfire_poison_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(backfire_poison_chance[cardlvl - 1]) + "% Chance to \
			apply" + str(backfire_poison_stacks) + " stacks of "  + PlayerUpgrade.POISON + " when attacked[/center]"
