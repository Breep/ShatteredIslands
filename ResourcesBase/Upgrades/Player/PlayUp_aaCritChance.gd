extends PlayerUpgrade
class_name PlayUp_aaCritChance

# =========================================
# === Boost auto-attack critical chance ===
# =========================================

@export var critChances: Array[int] # Critical chance increase per card lvl in %

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > critChances.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.critical_chance += critChances[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > critChances.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "Increase auto attack critical chance by " + str(critChances[cardlvl-1]) + "%"
