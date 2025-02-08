class_name FirePoisonFire
extends PlayerUpgrade

@export var poison_fire_damage: Array[int]
@export var poison_fire_stacks_lost: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.poison_fire_damage = poison_fire_damage[cardlvl - 1]
	stats.fire.poison_fire_stacks_lost = poison_fire_stacks_lost


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]For every " + str(poison_fire_stacks_lost) + " lost stack of \
			[color=#006400][wave freq=2.0 amp=5.0][hint=inflict 1 damage over time/stack]Poison\
			[/hint][/wave][/color], deals" + str(poison_fire_damage[cardlvl - 1]) + \
			"% damage of their max health[/center]"
