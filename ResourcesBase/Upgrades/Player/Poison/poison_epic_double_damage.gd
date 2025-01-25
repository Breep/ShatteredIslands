extends PlayerUpgrade

class_name Poison_epic_poison_double_damage

@export var poison_epic_poison_double_damage: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_epic_poison_double_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.poison.poison_epic_double_damage += poison_epic_poison_double_damage[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_epic_poison_double_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Poison inflict damage X" + str(poison_epic_poison_double_damage[cardlvl - 1]) +"[/center]"
