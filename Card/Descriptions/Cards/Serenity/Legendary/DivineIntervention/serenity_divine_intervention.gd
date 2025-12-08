class_name SerenityDivineIntervention
extends CharacterUpgrade

@export var _base_hp_threshold_percent: Array[float]
@export var _base_regen_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.LEGENDARY

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Divine Intervention: Wrong cardlvl: ", cardlvl)
		return
	
	stats.serenity.divine_intervention_activated = true
	stats.serenity.divine_intervention_hp_threshold_percent = _base_hp_threshold_percent[cardlvl - 1]
	stats.serenity.divine_intervention_regen_amount = _base_regen_amount[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Divine Intervention: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "The first time a hero allied reach " + str(_base_hp_threshold_percent[cardlvl - 1]) + "% HP, cleanse entirely and apply " + str(_base_regen_amount[cardlvl - 1]) + " regen to him"
