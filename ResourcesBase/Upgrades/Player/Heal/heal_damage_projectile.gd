class_name HealDamageProjectile
extends PlayerUpgrade

@export var heal_projectile_damage: Array[int]
@export var heal_projectile_chance: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > heal_projectile_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.heal.heal_projectile_activated = true
	stats.heal.heal_projectile_damage = heal_projectile_damage[cardlvl - 1]
	stats.heal.heal_projectile_chance  = heal_projectile_chance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > heal_projectile_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Each "  + PlayerUpgrade.HEAL +  " has a " + \
			str(heal_projectile_chance) + "% chance to launch a projectile at the \
			nearest enemy, dealing " + str(heal_projectile_damage[cardlvl - 1]) + " "  + PlayerUpgrade.MAGICAL_DAMAGE + "[/center]"
