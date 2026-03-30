class_name ChickenShellArmor
extends HeroUpgrade

@export var _block_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var block_stack: int = _block_stacks[card_lvl - 1]
	
	print(str(_block_stacks[card_lvl - 1]))
	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		print("Cardlevel: " + str(card_lvl))
		print("Before: " + str(chicken.uid) + " " + str(chicken.stats.block) )
		chicken.stats.block += block_stack
		print("After: " + str(chicken.uid) + " " + str(chicken.stats.block) )
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shell armor: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_block_stacks[cardlvl - 1]).pad_decimals(0)
	return "Add " + c + " block stack to chicken on hatch."
