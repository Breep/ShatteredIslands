class_name ChickenDoctorChicken
extends HeroUpgrade

@export var _heal_amounts: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var heal_amount: float = _heal_amounts[card_lvl - 1]
	
	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
#		ça devrait être chicken.target_module? mais le target module du chicken est pas encore fonctionnel
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)

		if target == null: return
		target.take_heal(heal_amount, false, &"Doctor Chicken", chicken) 
		#chicken.heal(target, heal_amount, &"Doctor Chicken")
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Doctor Chicken: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	var h: String = str(_heal_amounts[cardlvl - 1]).pad_decimals(0)
	return "Quand un poulet allié apparaît, soigne un allié aléatoire de " + h + "."
