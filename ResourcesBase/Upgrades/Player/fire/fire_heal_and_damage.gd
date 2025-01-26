class_name FireHealingFire
extends PlayerUpgrade

@export var healing_fire_area_damage: Array[float]
@export var healing_fire_area_heal: Array[float]
@export var healing_fire_area_period: int
@export var healing_fire_area_range: int

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > healing_fire_area_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.fire.healing_fire_area_damage = healing_fire_area_damage[cardlvl-1]
	player.stats.fire.healing_fire_area_heal = healing_fire_area_heal[cardlvl-1]
	player.stats.fire.healing_fire_area_period = healing_fire_area_period
	player.stats.fire.healing_fire_area_range = healing_fire_area_range


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > healing_fire_area_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Heal allies for " + str(healing_fire_area_heal[cardlvl-1]) + "% of their max hp \
			and damage enemies for " + str(healing_fire_area_damage[cardlvl - 1]) + \
			"% of their max hp in a " + str(healing_fire_area_range) + "m range \
			every " + str(healing_fire_area_period) + "s.[/center]"
