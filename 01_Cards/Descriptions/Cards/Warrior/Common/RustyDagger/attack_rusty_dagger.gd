class_name AttackRustyDagger
extends HeroUpgrade

@export var _chance: Array[float]
@export var _poison_stacks: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rusty Dagger: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance[card_lvl - 1]
	var stacks: float = _poison_stacks[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Rusty Dagger"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id): return
		var target: Entity = _cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if target == null: return
		ctx.hero.add_stack_sender.inflict_condition_stacks(target, stacks, Alteration.Type.POISON, &"Rusty Dagger")

	ctx.battle_callbacks.register_battle_start(&"Rusty Dagger", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Rusty Dagger", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Rusty Dagger")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rusty Dagger: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance[cardlvl - 1]) + "% chance to inflict " + str(_poison_stacks[cardlvl - 1]) + " poison stacks on attack."
