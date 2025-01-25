extends PlayerUpgrade

class_name Heal_damage_projectile

@export var heal_damage_projectile: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_damage_projectile.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.heal.heal_damage_projectile += heal_damage_projectile[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_damage_projectile.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Everytime a heal is done by the player, 50% chance to launch a magic projectile to the closest enemy dealing " + str(heal_damage_projectile[cardlvl - 1]) +" damage[/center]"
