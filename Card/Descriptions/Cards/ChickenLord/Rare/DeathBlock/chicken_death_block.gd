class_name ChickenDeathBlock
extends HeroUpgrade

@export var _block_amounts: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var block_amount: int = _block_amounts[card_lvl - 1]
	ctx.hero.families_stats.chicken_lord.on_chicken_death_callbacks.append(func(cb_vars: Dictionary) -> void:
		var dead_chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(dead_chicken):
			return
		
		var ally_chickens: Array[Chicken] = cb_vars.get(FamilyChickenLordStats.CbVars.ALIVE_CHICKENS)
		if ally_chickens == null or ally_chickens.is_empty():
			return
		
		var closest_ally_chicken: Chicken = ally_chickens[0]
		for ally_chicken in ally_chickens:
			var ally_chicken_distance: float = ally_chicken.global_position.distance_squared_to(dead_chicken.global_position)
			var closest_ally_chicken_distance: float = closest_ally_chicken.global_position.distance_squared_to(dead_chicken.global_position)
			if ally_chicken_distance < closest_ally_chicken_distance:
				closest_ally_chicken = ally_chicken
		
		# Phase 4 rework: BLOCK is now a BlockAlteration stack.
		if closest_ally_chicken.alterations_module != null:
			closest_ally_chicken.alterations_module.add_block_stacks(block_amount)
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Death Block: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "À la mort d'un poulet, donne " + str(_block_amounts[cardlvl - 1]) + " stacks de [[BLOCK]] au poulet allié le plus proche."
