extends PlayerUpgrade
class_name PlayUp_aaChanceToPacify

# =================================
# === Chance to Pacify on AA ===
# =================================

@export var chanceToPacify: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chanceToPacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.pacify_chance += chanceToPacify[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chanceToPacify.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(chanceToPacify[cardlvl-1]) + "% Chance to Pacify on Attack"
