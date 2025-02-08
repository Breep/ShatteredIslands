extends PlayerUpgrade
class_name AttackChanceToPoison

@export var poison_stacks_chance: Array[int]
@export var poison_stacks_amount: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_stacks_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.poison_stacks_amount = poison_stacks_amount
	stats.auto_attack.poison_stacks_chance = poison_stacks_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_stacks_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(poison_stacks_chance[cardlvl - 1]) + "% of chance to apply " + \
			str(poison_stacks_amount) + "stacks of [color=#006400][wave freq=2.0 amp=5.0]poison\
			[/wave][/color] on attack[/center]"
