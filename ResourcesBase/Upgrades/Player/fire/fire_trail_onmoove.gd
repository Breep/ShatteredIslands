class_name FireTrail
extends PlayerUpgrade

@export var trail_damage: Array[float]
@export var trail_life_time: float
@export var trail_period: float

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > trail_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.trail_damage = trail_damage[cardlvl-1]
	player.stats.fire.trail_life_time = trail_life_time
	player.stats.fire.trail_period = trail_period


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > trail_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]When moving, leave a trail of fire behind. Trail of fire deals " + \
			str(trail_damage[cardlvl - 1]) + "% of enemy current hp damage every" + \
			str(trail_period) + "sec and last " + str(trail_life_time) + "s.[/center]"
