class_name DefenseToxicFiltrationLayer
extends CharacterUpgrade

@export var _base_efficiency: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Toxic Filtration Layer: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.toxic_filtration_layer_activated = true
	stats.defense.toxic_filtration_layer_efficiency = _base_efficiency[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Toxic Filtration Layer: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Shield can block poison damage with " + str(_base_efficiency[cardlvl - 1]) + "% value"
