extends PlayerUpgrade
class_name PlayUp_aaDrainLife

# =================================
# === DrainLife on AA ===
# =================================

@export var DrainLife: Array[int] # Auto attack damage increase per card lvl

func apply(player: Character, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > DrainLife.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return
	player.stats.autoAttack.drain_life += DrainLife[cardlvl-1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > DrainLife.size():
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"
	return str(DrainLife[cardlvl-1]) + "Drain Life on Attack"
