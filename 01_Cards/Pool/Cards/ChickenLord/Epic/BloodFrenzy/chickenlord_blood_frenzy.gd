class_name ChickenLordBloodFrenzy
extends CardEffect

@export var _ad_per_deaths: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var ad: float = _ad_per_deaths[card_lvl - 1]

	ctx.hero.families_stats.chicken_lord.on_chicken_death_callbacks.append(func(cb_vars: Dictionary) -> void:
		var alive_chickens: Array[Chicken] = cb_vars.get(FamilyChickenLordStats.CbVars.ALIVE_CHICKENS)
		var death_count: int = cb_vars.get(FamilyChickenLordStats.CbVars.DEATH_COUNT, 0)
		if alive_chickens == null or alive_chickens.is_empty() or death_count <= 0:
			return
		for chicken: Chicken in alive_chickens:
			if not is_instance_valid(chicken): continue
			var mod := StatModifier.new()
			mod.calc_type = StatModifier.CalcType.ADD
			mod.id = &"BloodFrenzy"
			mod.stat_type = EntityStats.StatType.AD
			mod.value = ad * death_count
			chicken.stat_modifiers_registry.register_modifier(mod)
	)

	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		var death_count: int = cb_vars.get(FamilyChickenLordStats.CbVars.DEATH_COUNT, 0)
		if not is_instance_valid(chicken) or death_count <= 0: return
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.id = &"BloodFrenzy"
		mod.stat_type = EntityStats.StatType.AD
		mod.value = ad * death_count
		chicken.stat_modifiers_registry.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("BloodFrenzy: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "À la mort d'un poulet, augmente l'AD de tous les poulets de " + str(_ad_per_deaths[cardlvl - 1]) + "."
