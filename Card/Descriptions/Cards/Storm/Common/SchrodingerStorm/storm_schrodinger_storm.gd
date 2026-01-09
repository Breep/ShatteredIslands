class_name StormSchrodingerStorm
extends HeroUpgrade

@export var _stacks: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Schrodinger Storm: Wrong cardlvl: ", cardlvl)
		return
	
	stats.storm.schrodinger_storm_activated = true
	stats.storm.schrodinger_storm_amount = _stacks[cardlvl - 1]

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Schrodinger Storm: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var val = str(_stacks[cardlvl - 1]).pad_decimals(0)
	
	return "On Rank Change, inflict " + val + " random stacks to a random entity."
