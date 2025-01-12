extends PlayerUpgrade
class_name PlayUp_aaChanceToStun

# =================================
# === Chance to stun on AA ===
# =================================

@export var ChanceToStun: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToStun.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.damage += ChanceToStun[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToStun.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToStun[cardlvl-1]) + "% Chance to Stun on Attack"
