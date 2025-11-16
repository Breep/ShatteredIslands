class_name AttackArcaneStaff
extends CharacterUpgrade

@export var _chance_percent: Array[float]
@export var _mana_gain: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Arcane Staff: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.arcane_staff_activated = true
	stats.auto_attack.arcane_staff_chance = _chance_percent[cardlvl - 1]
	stats.auto_attack.arcane_staff_mana_gain = _mana_gain[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Arcane Staff: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance_percent[cardlvl - 1]) + "% chance to regen " + str(_mana_gain[cardlvl - 1]) + " mana on hit."
