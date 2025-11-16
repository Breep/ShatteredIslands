class_name AttackFightBack
extends CharacterUpgrade

@export var _increase_dodge: Array[float] 
@export var _increase_attack_damage: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("fight back: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.fight_back_activated = true
	stats.auto_attack.fight_back_increase_dodge = _increase_dodge[cardlvl - 1]
	stats.auto_attack.fight_back_increase_attack_damage = _increase_attack_damage[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("fight back: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". On dodge, increase attack damage by " + str(_increase_attack_damage[cardlvl - 1]) + "."
