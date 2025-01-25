extends PlayerUpgrade

class_name Shadow_shadow_bolt

@export var shadow_shadow_bolt: Array[int]


func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shadow_shadow_bolt.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.shadow.shadow_shadow_boltbolt += shadow_shadow_bolt[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shadow_shadow_bolt.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]For every 1m you moove, lanch a shadowbolt to the furthest enemy dealing " + str(shadow_shadow_bolt[cardlvl - 1]) +" damage[/center]"
