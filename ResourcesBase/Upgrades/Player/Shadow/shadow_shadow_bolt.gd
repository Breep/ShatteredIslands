class_name ShadowShadowBolt
extends PlayerUpgrade

@export var shadow_bolt_damage: Array[int]
@export var shadow_bolt_distance: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_bolt_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.shadow.shadow_bolt_activated = true
	stats.shadow.shadow_bolt_damage = shadow_bolt_damage[cardlvl - 1]
	stats.shadow.shadow_bolt_distance = shadow_bolt_distance


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_bolt_damage.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For every 1m you move, launch a Shadowbolt at the furthest enemy dealing "\
			+ str(shadow_bolt_damage[cardlvl - 1]) + " " + PlayerUpgrade.MAGICAL_DAMAGE + "[/center]"
