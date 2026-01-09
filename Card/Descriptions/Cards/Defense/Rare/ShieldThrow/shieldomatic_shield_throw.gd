class_name DefenseShieldThrow
extends HeroUpgrade

@export var _threshold: Array[float]
@export var _damage: Array[float]
@export var _shield_return: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong cardlvl: ", cardlvl)
		return
	
	stats.defense.shield_throw_activated = true
	stats.defense.shield_throw_threshold = _threshold[cardlvl - 1]
	stats.defense.shield_throw_damage = _damage[cardlvl - 1]
	stats.defense.shield_throw_return_shield = _shield_return[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Throw: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_threshold[cardlvl - 1]) + " [[SHIELD]] generated, throw a shield. Deal " + str(_damage[cardlvl - 1]) + " [[MAGICAL_DAMAGE]] and bounce between all enemies. Generate " + str(_shield_return[cardlvl - 1]) + " [[SHIELD]] for each enemy hit."
