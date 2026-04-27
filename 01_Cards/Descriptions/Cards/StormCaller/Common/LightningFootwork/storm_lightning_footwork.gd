class_name StormLightningFootwork
extends HeroUpgrade

@export var _base_dodge_increase: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Footwork: Wrong card_lvl: ", card_lvl)
		return

	var dodge_increase: float = _base_dodge_increase[card_lvl - 1]
	var state := {&"bonus": 0.0}

	# Stat modifier: dodge (starts at 0, updated on crit)
	var mod := StatModifier.new()
	mod.id = &"Lightning Footwork"
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = 0.0
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)

	# Action modifier: reset bonus after dodge
	var action_modifier := ActionModifier.new()
	action_modifier.action_type = Utils.ActionCategory.DODGE
	action_modifier.id = &"Lightning Footwork"
	action_modifier.is_one_time_effect = false
	action_modifier.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		state[&"bonus"] = 0.0
		var update_mod := StatModifier.new()
		update_mod.id = &"Lightning Footwork"
		update_mod.stat_type = EntityStats.StatType.DODGE
		update_mod.calc_type = StatModifier.CalcType.ADD
		update_mod.value = 0.0
		update_mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.register_modifier(update_mod)
	ctx.action_modifiers.register_modifier(action_modifier)

	# On crit: accumulate dodge bonus
	var storm_stats: FamilyStormCallerStats = ctx.hero.families_stats.storm_caller
	storm_stats.on_crit_callbacks.append(
		func(_target: Entity, _base_value: float, _real_value: float) -> void:
			state[&"bonus"] += dodge_increase
			var update_mod := StatModifier.new()
			update_mod.id = &"Lightning Footwork"
			update_mod.stat_type = EntityStats.StatType.DODGE
			update_mod.calc_type = StatModifier.CalcType.ADD
			update_mod.value = state[&"bonus"]
			update_mod.tags = [StatModifier.TagType.CARD]
			ctx.stat_modifiers.register_modifier(update_mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Footwork: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each crit increase dodge by " + str(_base_dodge_increase[cardlvl - 1]) + "%. Reset after each dodge"
