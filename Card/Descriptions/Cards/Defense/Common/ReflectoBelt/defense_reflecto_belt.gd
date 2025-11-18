class_name DefenseReflectoBelt
extends CharacterUpgrade

@export var _shield_threshold: Array[float]
@export var _attacks_count: Array[float] # Note: Array[float] pour le scaling, on convertira en int
@export var _damage_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reflecto Belt: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.reflecto_belt_activated = true
	stats.defense.reflecto_belt_shield_threshold = _shield_threshold[cardlvl - 1]
	stats.defense.reflecto_belt_attacks_count = int(_attacks_count[cardlvl - 1])
	stats.defense.reflecto_belt_damage_percent = _damage_percent[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reflecto Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_shield_threshold[cardlvl - 1]) + " [[SHIELD]] broken, your next " + str(_attacks_count[cardlvl - 1]) + " attacks deal +" + str(_damage_percent[cardlvl - 1]) + "% [[PHYSICAL_DAMAGE]]."
