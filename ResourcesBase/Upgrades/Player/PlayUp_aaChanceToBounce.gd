extends PlayerUpgrade
class_name PlayUp_aaChanceToBounce

# =================================
# === Chance to Bounce on AA ===
# =================================

@export var ChanceToBounce: Array[int] # Auto attack damage increase per card lvl

func apply(player: Player, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > ChanceToBounce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.damage += ChanceToBounce[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > ChanceToBounce.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(ChanceToBounce[cardlvl-1]) + "% Chance to Bounce Attack"
