class_name FireMeteor
extends PlayerUpgrade

@export var meteor_damage: Array[int]
@export var meteor_area_range:  Array[float]
@export var meteor_cooldown: float
@export var meteor_deploy_time: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > meteor_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.meteor_activated = true
	stats.fire.meteor_area_range = meteor_area_range[cardlvl - 1]
	stats.fire.meteor_cooldown = meteor_cooldown
	stats.fire.meteor_damage = meteor_damage[cardlvl - 1]
	stats.fire.meteor_deploy_time = meteor_deploy_time

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > meteor_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center] Spawn meteor at enemy position. Meteor deals"  + PlayerUpgrade.MAGICAL_DAMAGE + " equal to " + str(meteor_damage[cardlvl - 1]) + "% of enemies max hp \
			within " + str(meteor_area_range[cardlvl - 1]) + "m radius"
			
	#return "[center] Spawn meteor at enemy position that takes " +  str(meteor_deploy_time[cardlvl - 1]) + \
			#"s to come down. Meteor deals"  + PlayerUpgrade.MAGICAL_DAMAGE + " equal to " + str(meteor_damage) + "% of enemies max hp \
			#within " + str(meteor_area_range) + "m radius. A new meteor spawn after " + \
			#str(meteor_cooldown) + "s[/center]"
