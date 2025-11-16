class_name AttackRustyDagger
extends CharacterUpgrade

@export var _chance: Array[float] 
@export var _poison_stacks: Array[float]

func apply(stats: FamiliesStats, cardlvl: int) -> void:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("rusty dagger: Wrong cardlvl: ", cardlvl)
		return
	
	stats.auto_attack.rusty_dagger_activated = true
	stats.auto_attack.rusty_dagger_chance = _chance[cardlvl - 1]
	stats.auto_attack.rusty_dagger_poison_stacks = _poison_stacks[cardlvl - 1]


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > COMMON_CARD_MAX_LEVEL:
		printerr("rusty dagger: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	return str(_chance[cardlvl - 1]) + "% chance to inflict " + str(_poison_stacks[cardlvl - 1]) + " poison stacks on attack."
