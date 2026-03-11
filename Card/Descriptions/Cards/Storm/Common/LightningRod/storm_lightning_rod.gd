class_name StormLightningRod
extends HeroUpgrade

@export var _base_threshold: Array[float]
@export var _base_resistance: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong card_lvl: ", card_lvl)
		return

	var threshold: float = _base_threshold[card_lvl - 1]
	var resistance: float = _base_resistance[card_lvl - 1]
	var state := {&"is_active": false}

	var _apply_modifier := func(enabled: bool) -> void:
		if enabled == state[&"is_active"]: return
		state[&"is_active"] = enabled
		if enabled:
			for action_type in Utils.get_all_actions():
				var mod := StatModifier.new()
				mod.id = &"Lightning Rod" + str(action_type)
				mod.stat_type = EntityStats.StatType.CRIT_RESISTANCE
				mod.action_type = action_type
				mod.calc_type = StatModifier.CalcType.ADD
				mod.value = resistance
				mod.tags = [StatModifier.TagType.CARD]
				ctx.stat_modifiers.register_modifier(mod)
		else:
			for action_type in Utils.get_all_actions():
				ctx.stat_modifiers.remove_modifier(EntityStats.StatType.CRIT_RESISTANCE, &"Lightning Rod" + str(action_type), action_type)

	var _on_health_changed: Callable
	_on_health_changed = func(new_health: float) -> void:
		if ctx.hero.stats.health_max == 0: return
		var percent: float = (new_health / ctx.hero.stats.health_max) * 100.0
		if percent > threshold:
			_apply_modifier.call(true)
		else:
			_apply_modifier.call(false)

	ctx.battle_callbacks.register_battle_start(&"Lightning Rod", func() -> void:
		state[&"is_active"] = false
		if not ctx.hero.stats.health_changed.is_connected(_on_health_changed):
			ctx.hero.stats.health_changed.connect(_on_health_changed)
		# Initial check
		_on_health_changed.call(ctx.hero.stats.health)
	)
	ctx.battle_callbacks.register_battle_end(&"Lightning Rod", func() -> void:
		if ctx.hero.stats.health_changed.is_connected(_on_health_changed):
			ctx.hero.stats.health_changed.disconnect(_on_health_changed)
		_apply_modifier.call(false)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Lightning Rod: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var t = str(_base_threshold[cardlvl - 1]).pad_decimals(0)
	var r = str(_base_resistance[cardlvl - 1]).pad_decimals(0)
	return "While above " + t + "% HP, gain " + r + " Critical Resistance."
