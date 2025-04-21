class_name DefenseMysticalShoulders
extends PlayerUpgrade

@export var _magic_damage: int # Amount of magic damage needed to proc this skill
@export var _percents_inc: Array[float] # % of magic resist gained each time this skill proc
@export var _percents_max: Array[float] # Maximum % of magic resist

func apply(stats: CharacterStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.mystical_shoulders_percent_max = _percents_max[cardlvl - 1]
	stats.defense.mystical_shoulders_percent_inc = _percents_inc[cardlvl - 1]
	stats.defense.mystical_shoulders_magic_damage = _magic_damage
	stats.defense.mystical_shoulders_activated = true


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 5:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "[center]Every " + str(_magic_damage) + " " + MAGICAL_DAMAGE + "blocked, increase magic resist by " + str(_percents_inc[cardlvl - 1]) \
			+ "% up to " + str(_percents_max[cardlvl - 1]) + "%[/center]"
