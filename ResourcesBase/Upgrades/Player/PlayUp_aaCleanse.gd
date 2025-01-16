extends PlayerUpgrade
class_name PlayUp_aaCleanse

# =================================
# === cleanse on AA ===
# =================================

@export var cleanse: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > cleanse.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.cleanse += cleanse[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > cleanse.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return "Cleanse " + str(cleanse[cardlvl-1]) + " Debuff on Attack"
