extends PlayerUpgrade
class_name PlayUp_aaChanceToIgnite

# =================================
# === Chance to Ignite on AA ===
# =================================

@export var chanceToIgnite: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > chanceToIgnite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.ignite_chance += chanceToIgnite[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > chanceToIgnite.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(chanceToIgnite[cardlvl-1]) + "% Chance to Ignite on Attack"
