class_name FireExpanseUniverse
extends CharacterUpgrade

@export var _ignite_stacks: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong cardlvl: ", cardlvl)
		return
	
	# On utilise stats.fire
	stats.fire.expanse_universe_activated = true
	stats.fire.expanse_universe_ignite_stacks = _ignite_stacks[cardlvl - 1]
	stats.fire.expanse_universe_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Expanse Universe: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Inflict " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE]] stacks every " + str(_period[cardlvl - 1]) + "s."
