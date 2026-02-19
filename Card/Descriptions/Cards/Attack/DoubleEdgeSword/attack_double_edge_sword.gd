class_name AttackDoubleEdgeSword
extends HeroUpgrade

@export var _damage_percent: Array[int] # % of damage increased when changing target
@export var _attacks_number: Array[int] # Number of attack boosted


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var dmg_pct: int = _damage_percent[card_lvl - 1]
	var atk_count: int = _attacks_number[card_lvl - 1]
	var state := {&"attacks_left": 0, &"last_target": null}

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Double Edge Sword"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_hit_logic_callback = func(cb_vars: Dictionary) -> void:
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if target != state[&"last_target"]:
			state[&"last_target"] = target
			state[&"attacks_left"] = atk_count
		if state[&"attacks_left"] > 0:
			state[&"attacks_left"] -= 1
			aa_mod.damage_mult = dmg_pct / 100.0
		else:
			aa_mod.damage_mult = 0.0

	ctx.battle_callbacks.register_battle_start(&"Double Edge Sword", func() -> void:
		state[&"attacks_left"] = 0
		state[&"last_target"] = null
		aa_mod.damage_mult = 0.0
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Double Edge Sword", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Double Edge Sword")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > 3:
		printerr("Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "[center]When switching target, the next " + str(_attacks_number[cardlvl - 1]) + " attacks deal " + \
			str(_damage_percent[cardlvl - 1]) + " % more damage[/center]"
