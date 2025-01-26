class_name AttackMaxHp
extends PlayerUpgrade

@export var increase_max_hp_amount: Array[int] # Auto attack damage increase per card lvl
@export var increase_max_hp_period: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > increase_max_hp_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.increase_max_hp_activated = true
	player.stats.auto_attack.increase_max_hp_amount = increase_max_hp_amount[cardlvl-1]
	player.stats.auto_attack.increase_max_hp_period = increase_max_hp_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > increase_max_hp_amount.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(increase_max_hp_period) + " attacks gain " + \
			str(increase_max_hp_amount[cardlvl - 1]) + " max hp.[/center]"
