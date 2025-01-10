extends PlayerUpgrade
class_name PlayUp_aaSpeed

# ===============================
# === Boost auto-attack speed ===
# ===============================

@export var speeds: Array[int] # Auto attack speed increase per card lvl in %

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > speeds.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	var speedMultiplier = remap(speeds[cardlvl-1], 0, 100, 1, 2) # Adding 30% is like multiplying by 1.3
	player.stats.autoAttack.speed *= speedMultiplier

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > speeds.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "Increase auto attack speed by " + str(speeds[cardlvl-1]) + "%"
