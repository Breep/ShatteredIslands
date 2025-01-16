extends PlayerUpgrade
class_name PlayUp_aaChanceToNecrosis

# =================================
# === Chance to Necrosis on AA ===
# =================================

@export var ChanceToNecrosis: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToNecrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.necrosis_chance += ChanceToNecrosis[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToNecrosis.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToNecrosis[cardlvl-1]) + "% Chance to Necrosis on Attack"
