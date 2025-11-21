class_name FireCosmicBolt
extends CharacterUpgrade

@export var _damage_per_stack: Array[float]
@export var _bounce_chance_per_stack: Array[float]
@export var _period: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.RARE

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong cardlvl: ", cardlvl)
		return
	
	stats.fire.cosmic_bolt_activated = true
	stats.fire.cosmic_bolt_damage_per_stack = _damage_per_stack[cardlvl - 1]
	stats.fire.cosmic_bolt_bounce_chance_per_stack = _bounce_chance_per_stack[cardlvl - 1]
	stats.fire.cosmic_bolt_period = _period[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return "Every " + str(_period[cardlvl - 1]) + "s, fire a bolt. Deals " + str(_damage_per_stack[cardlvl - 1]) + " damage per [[IGNITE]] stack. " + str(_bounce_chance_per_stack[cardlvl - 1]) + "% chance per [[IGNITE]] stack to bounce."
