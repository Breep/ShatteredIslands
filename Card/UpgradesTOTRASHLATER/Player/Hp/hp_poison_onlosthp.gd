class_name HpPoisonOnLostHp
extends PlayerUpgrade

@export var poison_by_lost_hp_stacks: Array[int]
@export var poison_by_lost_hp_period: float
@export var poison_by_lost_hp_hp_number: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_by_lost_hp_stacks.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.hp.poison_by_lost_hp_activated = true
	stats.hp.poison_by_lost_hp_stacks = poison_by_lost_hp_stacks[cardlvl - 1]
	stats.hp.poison_by_lost_hp_hp_number = poison_by_lost_hp_hp_number
	stats.hp.poison_by_lost_hp_period = poison_by_lost_hp_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_by_lost_hp_stacks.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(poison_by_lost_hp_period) + "s, for every " + \
			str(poison_by_lost_hp_hp_number) + "HP lost compared to max HP, inflict " + \
			str(poison_by_lost_hp_stacks[cardlvl - 1]) + " stacks of " + PlayerUpgrade.POISON + "[/center]"
