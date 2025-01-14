extends PlayerUpgrade
class_name PlayUp_aaChanceToPoison

# =================================
# === Chance to Poison on AA ===
# =================================

@export var chanceToPoison: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chanceToPoison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.poison_chance += chanceToPoison[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chanceToPoison.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(chanceToPoison[cardlvl-1]) + "% Chance to Poison on Attack"
