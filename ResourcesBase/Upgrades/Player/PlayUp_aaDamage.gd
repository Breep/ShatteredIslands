extends PlayerUpgrade
class_name PlayUp_aaDamage

# =================================
# === Boost auto-attack dammage ===
# =================================

@export var damages: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.dammage += damages[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "Increase auto attack dammage by " + str(damages[cardlvl-1])
