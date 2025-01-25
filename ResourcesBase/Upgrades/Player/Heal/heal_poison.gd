extends PlayerUpgrade

class_name Heal_poison_onheal

@export var heal_poison_onheal: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_poison_onheal.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_poison += heal_poison_onheal[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_poison_onheal.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every time you heal an ally, you apply" + str(heal_poison_onheal[cardlvl - 1]) +"stacks of Poison to a random enemy[/center]"
