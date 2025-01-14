extends PlayerUpgrade
class_name PlayUp_aaChanceToDoubleAttack

# =================================
# === Chance to ChanceToDoubleAttack on AA ===
# =================================

@export var ChanceToDoubleAttack: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToDoubleAttack.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.doubleAttack_chance += ChanceToDoubleAttack[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToDoubleAttack.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToDoubleAttack[cardlvl-1]) + "% Chance to Double Attack"
