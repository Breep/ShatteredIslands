class_name ChickenShellArmor
extends CardEffect

@export var _block_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var block_stack: int = _block_stacks[card_lvl - 1]
	
	print(str(_block_stacks[card_lvl - 1]))
	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		if chicken.alterations != null:
			chicken.alterations.add_stack(Alteration.Type.BLOCK, block_stack)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shell armor: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_block_stacks[cardlvl - 1]).pad_decimals(0)
	return "Ajoute " + c + " stacks de [[BLOCK]] aux poulets à l'éclosion."
