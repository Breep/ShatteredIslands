class_name FireEndOfTheWorld
extends HeroUpgrade

@export var _stack_multiplier: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("End Of The World: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.end_of_the_world_activated = true
	stats.fire.end_of_the_world_stack_multiplier = _stack_multiplier[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("End Of The World: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Meteor execute enemies below " + str(_stack_multiplier[cardlvl - 1]) + " * [[IGNITE_STACK]]"
