class_name AttackFireDamage
extends PlayerUpgrade

@export var fire_attack_damage: Array[int]
@export var fire_attack_period: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > fire_attack_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.fire_attack_activated = true
	player.stats.auto_attack.fire_attack_damage = fire_attack_damage[cardlvl - 1]
	player.stats.auto_attack.fire_attack_period = fire_attack_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > fire_attack_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(fire_attack_period) + " attacks, also deal" + \
			str(fire_attack_damage[cardlvl - 1]) + "% of the enemy current life \
			as magic damage[/center]"
