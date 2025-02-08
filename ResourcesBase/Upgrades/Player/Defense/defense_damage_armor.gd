class_name DefenceDamageOnArmorLost
extends PlayerUpgrade

@export var shield_strike_damage_percent: Array[float]
@export var shield_strike_period: float

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > shield_strike_damage_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.shield_strike_damage_percent = shield_strike_damage_percent[cardlvl-1]
	stats.defense.shield_strike_period = shield_strike_period

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > shield_strike_damage_percent.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(shield_strike_period) + "s deal damage equal to" + \
			str(shield_strike_damage_percent[cardlvl - 1]) + "% of lost armor[/center]"
