class_name ChickenLordBigEggs
extends HeroUpgrade

@export var _big_egg_numbers: Array[int]
@export var _chicken_per_eggs: Array[int]
@export var _time_before_spawns: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var big_egg_number: int = _big_egg_numbers[card_lvl - 1]
	var chicken_per_egg: int = _chicken_per_eggs[card_lvl - 1]
	var time_before_spawn: float = _time_before_spawns[card_lvl - 1]
	
	var big_egg_mod := ActionModifier.new()
	big_egg_mod.action_type = Utils.ActionCategory.SUMMON
	big_egg_mod.is_one_time_effect = false
	big_egg_mod.id = &"Big Egg"
	big_egg_mod.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.ENTITY_TYPE) != Entity.EntityType.CHICKEN_EGG:
			return
		Verbose.warn("WADALUP")
		var em: Dictionary = cb_vars.get(ActionModifier.VarType.ENTITY_MODIFIER, {})
		var chicken_type = Utils.pick_random(ctx.hero.families_stats.chicken_lord.gifted_types, ctx.hero.battle_id)
		em[ChickenEgg.Modifier.CHICKEN_TYPE] = chicken_type
		em[ChickenEgg.Modifier.SCALE] = 2.0
		var hm: Array = em.get(ChickenEgg.Modifier.HATCH_MODIFIERS, [])
		var mod := HatchModifier.new()
		mod.id = &"Chicken Twins"
		mod.is_one_time_effect = false
		mod.before_hatch_callback = func(vars: Dictionary) -> void:
			vars[HatchModifier.VarType.SPAWN_COUNT] += chicken_per_egg
		hm.append(mod)
	
	ctx.periodic_timers.register_oneshot(time_before_spawn, func() -> void:
		ctx.hero.action_modifiers_registry.register_modifier(big_egg_mod)
		for i in big_egg_number:
			ctx.hero.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_arena_center(3), {})
		ctx.hero.action_modifiers_registry.unregister_modifier(big_egg_mod)
		)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("BloodFrenzy: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var ben: String = str(_big_egg_numbers[cardlvl - 1]).pad_decimals(0)
	var cpe: String = str(_chicken_per_eggs[cardlvl - 1]).pad_decimals(0)
	var tbs: String = str(_time_before_spawns[cardlvl - 1]).pad_decimals(0)
	return "After " + tbs + "s, spawn " + ben + " big eggs. Each hatch " + cpe + " gifted chickens."
