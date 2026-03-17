class_name ChickenChickenSwarm
extends HeroUpgrade

@export var _spawn_numbers_increase: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var spawn_number_increase: int = _spawn_numbers_increase[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.spawn_number_increase = spawn_number_increase


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chicken Swarm: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase the number of chicken spawn at the start of the battle by " + str(_spawn_numbers_increase[cardlvl - 1])
