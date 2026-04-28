class_name ChickenLordNaturalSelection
extends HeroUpgrade

@export var _evolution_times: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Natural Selection: Wrong card_lvl: ", card_lvl)
		return

	var evolution_time: float = _evolution_times[card_lvl - 1]

	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		if chicken is ChickenGifted: return

		chicken.periodic_timer_registry.register_oneshot(evolution_time, func() -> void:
			if not is_instance_valid(chicken) or chicken.is_dead(): return

			var chicken_type = Utils.pick_random(ctx.hero.families_stats.chicken_lord.gifted_types, ctx.hero.battle_id)
			if chicken_type == null: return

			var spawn_loc := SpawnLocationConfig.create_entity_relative(chicken, 0.5)

			# Use a temporary ActionModifier to force gifted type on the egg
			var evolution_mod := ActionModifier.new()
			evolution_mod.action_type = Utils.ActionCategory.SUMMON
			evolution_mod.is_one_time_effect = true
			evolution_mod.id = &"Natural Selection"
			evolution_mod.before_action_logic_callback = func(mod_vars: Dictionary) -> void:
				if mod_vars.get(ActionModifier.VarType.ENTITY_TYPE) != Entity.EntityType.CHICKEN_EGG:
					return
				var em: Dictionary = mod_vars.get(ActionModifier.VarType.ENTITY_MODIFIER, {})
				em[ChickenEgg.Modifier.CHICKEN_TYPE] = chicken_type

			ctx.hero.action_modifiers_registry.register_modifier(evolution_mod)
			ctx.hero.summon.summon_entity(Entity.EntityType.CHICKEN_EGG, spawn_loc, {
				ChickenEgg.Modifier.HATCH_TIME: 1.5,
			})
			ctx.hero.action_modifiers_registry.unregister_modifier(evolution_mod)

			# Kill the basic chicken
			chicken.stats.health = 0
		)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Natural Selection: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var t: String = str(_evolution_times[cardlvl - 1]).pad_decimals(0)
	return "Un poulet basique qui survit " + t + "s évolue en poulet doué."
