class_name ChickenAssistantChicken
extends HeroUpgrade

@export var _shield_amounts: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var shield_amount: float = _shield_amounts[card_lvl - 1]
	
	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
#		ça devrait être chicken.target_module? mais le target module du chicken est pas encore fonctionnel
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ALLY_INCLUDING_SELF)

		if target == null: return
		print("Chicken shielded " + str(shield_amount) + " to target " + target.name + " " + str(target.uid) )
		#chicken.inflict_condition_stacks(target, shield_amount, &"Doctor Chicken")
		target.take_condition_stacks(shield_amount, Stack.Type.SHIELD, false, &"Assistant Chicken", chicken)
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Assistant Chicken: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	var h: String = str(_shield_amounts[cardlvl - 1]).pad_decimals(0)
	return "When a friendly chicken is spawned, [[SHIELD]] a random ally of " + h + " amount."
