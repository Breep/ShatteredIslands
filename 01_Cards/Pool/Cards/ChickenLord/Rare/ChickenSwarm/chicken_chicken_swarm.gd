class_name ChickenChickenSwarm
extends CardEffect

@export var _spawn_numbers_increase: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var spawn_number_increase: int = _spawn_numbers_increase[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.spawn_number_increase = spawn_number_increase


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.hero.families_stats.chicken_lord.spawn_number_increase = 0


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chicken Swarm: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente le nombre de poulets au début du combat de " + str(_spawn_numbers_increase[cardlvl - 1]) + "."
