class_name DefenseForceField
extends CharacterUpgrade

@export var _period: Array[float]
@export var _lost_hp_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC

func apply(stats: FamiliesStats, cardlvl: int) -> void: # override
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Force Field: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.force_field_activated = true
	stats.defense.force_field_period = _period[cardlvl - 1]
	stats.defense.force_field_lost_hp_percent = _lost_hp_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Force Field: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + " s, gain shield equal to " + str(_lost_hp_percent[cardlvl - 1]) + "% lost HP."
