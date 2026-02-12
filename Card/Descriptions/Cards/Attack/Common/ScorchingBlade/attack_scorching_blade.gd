class_name ScorchingBlade
extends HeroUpgrade

@export var _damage_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorching Blade: Wrong card_lvl: ", card_lvl)
		return

	var percent: float = _damage_percent[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Scorching Blade"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_hit_logic_callback = func(cb_vars: Dictionary) -> void:
		pass # TODO: rework — needs PHYSICAL_DAMAGE from on_hit cb_vars
		# var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		# if target == null or not is_instance_valid(target): return
		# var damage_dealt: float = cb_vars.get(AutoAttackModifier.VarType.PHYSICAL_DAMAGE, 0)
		# var ignite_stacks: float = damage_dealt * (percent / 100.0)
		# if ignite_stacks > 0:
		#     ctx.hero.inflict_condition_stacks(target, ignite_stacks, Utils.StackType.IGNITE, &"Scorching Blade")

	ctx.battle_callbacks.register_battle_start(&"Scorching Blade", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Scorching Blade", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Scorching Blade")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Scorching Blade: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Inflict " + str(_damage_percent[cardlvl - 1]) + "% of attack damage as ignite."
