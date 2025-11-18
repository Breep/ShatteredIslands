class_name DefenseEnergyBarrier
extends CharacterUpgrade

@export var _shield_amount: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Energy Barrier: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.energy_barrier_activated = true
	stats.defense.energy_barrier_shield_amount = _shield_amount[cardlvl - 1]
	stats.defense.energy_barrier_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Energy Barrier: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Generate " + str(_shield_amount[cardlvl - 1]) + " [[SHIELD]] every " + str(_period[cardlvl - 1]) + " s."
