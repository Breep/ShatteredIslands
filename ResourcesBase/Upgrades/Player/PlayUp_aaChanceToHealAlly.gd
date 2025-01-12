extends PlayerUpgrade
class_name PlayUp_aaChanceToHealAlly

# =================================
# === Chance to ChanceToHealAlly on AA ===
# =================================

@export var ChanceToHealAlly: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToHealAlly.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.damage += ChanceToHealAlly[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToHealAlly.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToHealAlly[cardlvl-1]) + "% Chance to Heal Ally on Attack"
