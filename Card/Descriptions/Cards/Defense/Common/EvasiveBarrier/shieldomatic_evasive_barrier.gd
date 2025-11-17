class_name DefenseEvasiveBarrier
extends CharacterUpgrade

@export var _dodge_increase: Array[float]
@export var _shield_gain: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Evasive Barrier: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.evasive_barrier_activated = true
	stats.defense.evasive_barrier_dodge_increase = _dodge_increase[cardlvl - 1]
	stats.defense.evasive_barrier_shield_gain = _shield_gain[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Evasive Barrier: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Increase dodge by " + str(_dodge_increase[cardlvl - 1]) + ". Gain " + str(_shield_gain[cardlvl - 1]) + " shield on dodge."
