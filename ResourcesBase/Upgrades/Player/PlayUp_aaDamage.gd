extends PlayerUpgrade
class_name PlayUp_aaDamage

# =================================
# === Boost auto-attack damage ===
# =================================

@export var damages: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.damage += damages[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > damages.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "Increase auto attack damage by " + str(damages[cardlvl-1])
