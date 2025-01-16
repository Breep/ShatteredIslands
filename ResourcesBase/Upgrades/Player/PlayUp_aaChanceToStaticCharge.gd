extends PlayerUpgrade
class_name PlayUp_aaChanceToStaticCharge

# =================================
# === Chance to Static Charge on AA ===
# =================================

@export var ChanceToStaticCharge: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToStaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.staticCharge_chance += ChanceToStaticCharge[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToStaticCharge.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToStaticCharge[cardlvl-1]) + "% Chance to Static Charge on Attack"
