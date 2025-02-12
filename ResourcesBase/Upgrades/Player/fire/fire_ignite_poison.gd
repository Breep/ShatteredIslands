class_name FirePoisonFire
extends PlayerUpgrade

@export var poison_fire_damage: Array[int]
@export var poison_fire_stacks_lost: int

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > poison_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.poison.fire_poison_activated = true
	stats.poison.fire_poison_damage = poison_fire_damage[cardlvl - 1]
	stats.poison.fire_poison_stacks_lost = poison_fire_stacks_lost


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > poison_fire_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]For each " + str(poison_fire_stacks_lost) + " stack of " + PlayerUpgrade.POISON + " lost, deal " + \
			str(poison_fire_damage[cardlvl - 1]) + "% of the target's max hp as " + PlayerUpgrade.MAGICAL_DAMAGE + "[/center]"
