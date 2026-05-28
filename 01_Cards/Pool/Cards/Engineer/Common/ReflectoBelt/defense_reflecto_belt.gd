class_name DefenseReflectoBelt
extends HeroUpgrade

@export var _shield_threshold: Array[float]
@export var _attacks_count: Array[float] # Note: Array[float] pour le scaling, on convertira en int
@export var _damage_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reflecto Belt: Wrong card_lvl: ", card_lvl)
		return

	var threshold: float = _shield_threshold[card_lvl - 1]
	var attacks_count: int = int(_attacks_count[card_lvl - 1])
	var damage_percent: float = _damage_percent[card_lvl - 1]

	var state := {
		&"accumulated_loss": 0.0,
		&"attacks_left": 0,
		&"is_activated": false,
	}

	var _on_attack_consumption := func(_cb_vars: Dictionary) -> void:
		state[&"attacks_left"] -= 1
		if state[&"attacks_left"] <= 0:
			state[&"attacks_left"] = 0
			state[&"is_activated"] = false
			ctx.auto_attack_modifiers.unregister_modifier(&"Reflecto Belt")

	var _activate_buff := func() -> void:
		state[&"is_activated"] = true
		var aa_mod := AutoAttackModifier.new()
		aa_mod.id = &"Reflecto Belt"
		aa_mod.tags = [AutoAttackModifier.TagType.CARD]
		aa_mod.mul = 1.0 + (damage_percent / 100.0)
		aa_mod.is_one_time_effect = false
		aa_mod.additional_effect_callback = _on_attack_consumption
		ctx.auto_attack_modifiers.register_modifier(aa_mod)

	var _on_shield_broken := func(shield_stacks_lost: float) -> void:
		state[&"accumulated_loss"] += shield_stacks_lost
		if state[&"accumulated_loss"] >= threshold:
			state[&"accumulated_loss"] -= threshold
			state[&"attacks_left"] += attacks_count
			if not state[&"is_activated"]:
				_activate_buff.call()

	ctx.battle_callbacks.register_battle_start(&"Reflecto Belt", func() -> void:
		state[&"accumulated_loss"] = 0.0
		state[&"attacks_left"] = 0
		state[&"is_activated"] = false
		if not ctx.hero.alterations.shield_stack_broken.is_connected(_on_shield_broken):
			ctx.hero.alterations.shield_stack_broken.connect(_on_shield_broken)
	)
	ctx.battle_callbacks.register_battle_end(&"Reflecto Belt", func() -> void:
		if ctx.hero.alterations.shield_stack_broken.is_connected(_on_shield_broken):
			ctx.hero.alterations.shield_stack_broken.disconnect(_on_shield_broken)
		if state[&"is_activated"]:
			ctx.auto_attack_modifiers.unregister_modifier(&"Reflecto Belt")
			state[&"is_activated"] = false
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reflecto Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Tous les " + str(_shield_threshold[cardlvl - 1]) + " [[SHIELD]] brisés, les " + str(_attacks_count[cardlvl - 1]) + " prochaines attaques infligent +" + str(_damage_percent[cardlvl - 1]) + "% [[PHYSICAL_DAMAGE]]."
