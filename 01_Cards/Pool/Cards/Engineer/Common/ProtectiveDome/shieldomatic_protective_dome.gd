class_name DefenseProtectiveDome
extends CardEffect

@export var _armor_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protective Dome: Wrong card_lvl: ", card_lvl)
		return

	var resistance_value: float = _armor_percent[card_lvl - 1]
	var state := {&"is_active": false}

	var _update_modifier := func(current_shield: float) -> void:
		var mod := StatModifier.new()
		mod.id = &"Protective Dome"
		mod.stat_type = EntityStats.StatType.ARMOR
		mod.tags = [StatModifier.TagType.CARD]

		if current_shield > 0:
			if not state[&"is_active"]:
				mod.calc_type = StatModifier.CalcType.ADD
				mod.value = resistance_value
				ctx.stat_modifiers.register_modifier(mod)
				state[&"is_active"] = true
		else:
			if state[&"is_active"]:
				ctx.stat_modifiers.unregister_modifier(mod)
				state[&"is_active"] = false

	var _on_shield_changed: Callable
	_on_shield_changed = func(new_val: int) -> void:
		_update_modifier.call(float(new_val))

	ctx.battle_callbacks.register_battle_start(&"Protective Dome", func() -> void:
		state[&"is_active"] = false
		if not ctx.hero.alterations.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.alterations.shield_stacks_changed.connect(_on_shield_changed)
		_update_modifier.call(float(ctx.hero.alterations.shield_stacks))
	)
	ctx.battle_callbacks.register_battle_end(&"Protective Dome", func() -> void:
		if ctx.hero.alterations.shield_stacks_changed.is_connected(_on_shield_changed):
			ctx.hero.alterations.shield_stacks_changed.disconnect(_on_shield_changed)
		# Force deactivate
		if state[&"is_active"]:
			var mod := StatModifier.new()
			mod.id = &"Protective Dome"
			mod.stat_type = EntityStats.StatType.ARMOR
			ctx.stat_modifiers.unregister_modifier(mod)
			state[&"is_active"] = false
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Protective Dome")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protective Dome: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente l'[[ARMOR]] de " + str(_armor_percent[cardlvl - 1]) + "% tant que vous avez du [[SHIELD]]."
