class_name DefenseReflectoBelt
extends PlayerUpgrade

@export var _armor_stacks: int # Armor stacks lost needed to proc reflecto_belt effect
@export var _attack_increase_percent: Array[int] # % of damage increase for the next auto-attack

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.reflecto_belt_attack_increase_percent = _attack_increase_percent[cardlvl]
	stats.defense.reflecto_belt_armor_stacks = _armor_stacks
	stats.defense.reflecto_belt_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]After losing " + str(_armor_stacks) + ARMOR + ", increase next auto-attack by " + str(_attack_increase_percent[cardlvl]) + "%[/center]"
