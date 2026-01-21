class_name AttackBladeRush
extends HeroUpgrade

@export var _damage_increase: Array[float] 
@export var _duration: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Blade Rush: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.blade_rush_activated = true
	stats.auto_attack.blade_rush_damage = _damage_increase[cardlvl - 1]
	stats.auto_attack.blade_rush_duration = _duration[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Blade Rush: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "At the start of fight, increase attack damage by " + str(_damage_increase[cardlvl - 1]) + " for " + str(_duration[cardlvl - 1]) + " sec."
