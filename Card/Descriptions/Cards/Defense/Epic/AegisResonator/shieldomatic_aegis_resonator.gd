class_name DefenseAegisResonator
extends HeroUpgrade

@export var _period: Array[float]
@export var _total_shield: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.aegis_resonator_activated = true
	stats.defense.aegis_resonator_period = _period[cardlvl - 1]
	stats.defense.aegis_resonator_total_shield = _total_shield[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aegis Resonator: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, emit a pulse that gives " + str(_total_shield[cardlvl - 1]) + " [[SHIELD]], shared by all allies."
