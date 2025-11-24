class_name NecroPutridTouch
extends CharacterUpgrade

@export var _stacks: Array[int]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Putrid Touch: Wrong cardlvl: ", cardlvl)
		return
	
	stats.necro.necro_putrid_touch_activated = true
	stats.necro.necro_putrid_touch_stacks = _stacks[cardlvl - 1]
	stats.necro.necro_putrid_touch_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Putrid Touch: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, apply " + str(_stacks[cardlvl - 1]) + " stacks of [[NECROSIS]] to a random enemy."
