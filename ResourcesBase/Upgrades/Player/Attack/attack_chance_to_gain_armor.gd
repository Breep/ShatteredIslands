class_name AttackChanceToArmor
extends PlayerUpgrade

@export var armor_stacks_chance: Array[int]
@export var armor_stacks_amount: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > armor_stacks_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.armor_stacks_amount = armor_stacks_amount
	player.stats.auto_attack.armor_stacks_chance = armor_stacks_chance[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > armor_stacks_chance.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]" + str(armor_stacks_chance[cardlvl - 1]) + "% of chance to gain " + \
			str(armor_stacks_amount) + " stacks of [color=#8B4513][wave freq=2.0 amp=5.0]\
			armor[/wave][/color] on attack[/center]"
	
