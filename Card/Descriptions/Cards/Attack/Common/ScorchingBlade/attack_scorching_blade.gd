class_name ScorchingBlade
extends HeroUpgrade

@export var _damage_percent: Array[float] 

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Scorching Blade: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.scorching_blade_activated = true
	stats.auto_attack.scorching_blade_damage_percent = _damage_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Scorching Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Inflict " + str(_damage_percent[cardlvl - 1]) + "% of attack damage as ignite."
