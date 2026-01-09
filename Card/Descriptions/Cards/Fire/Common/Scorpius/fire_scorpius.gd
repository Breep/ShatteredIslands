class_name FireScorpius
extends HeroUpgrade

@export var _poison_stacks: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.scorpius_activated = true
	stats.fire.scorpius_poison_stacks = _poison_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorpius: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every [[METEOR]] apply " + str(_poison_stacks[cardlvl - 1]) + " [[POISON_STACK]]"
