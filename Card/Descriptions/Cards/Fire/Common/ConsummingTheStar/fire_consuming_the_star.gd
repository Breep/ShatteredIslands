class_name FireConsumingTheStar
extends HeroUpgrade

@export var _mana_burn: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Consuming the Star: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.consuming_the_star_activated = true
	stats.fire.consuming_the_star_mana_burn = _mana_burn[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Consuming the Star: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every [[METEOR]] burns " + str(_mana_burn[cardlvl - 1]) + " mana to enemies hit."
