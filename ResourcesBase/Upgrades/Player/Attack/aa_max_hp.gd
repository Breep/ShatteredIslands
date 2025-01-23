extends PlayerUpgrade
class_name AA_maxHp

@export var aa_gain_max_hp: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > aa_gain_max_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	
	player.stats.auto_attack.gain_max_hp += aa_gain_max_hp[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > aa_gain_max_hp.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "[center]Every 5 attack gain" + str(aa_gain_max_hp[cardlvl-1]) + " max HP [/center]"
