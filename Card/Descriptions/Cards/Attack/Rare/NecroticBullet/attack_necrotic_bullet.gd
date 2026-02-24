class_name AttackNecroticBullet
extends HeroUpgrade

@export var _chance: Array[int]
@export var _necrosis_stacks: Array[int]
@export var _rarity: Card.Rarity = Card.Rarity.RARE


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Necrotic Bullet: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = float(_chance[card_lvl - 1])
	var stacks: float = float(_necrosis_stacks[card_lvl - 1])

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Necrotic Bullet"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance): return
		var target = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if target == null or not is_instance_valid(target): return
		ctx.hero.inflict_condition_stacks(target, stacks, Stack.Type.NECROSIS, &"Necrotic Bullet")

	ctx.battle_callbacks.register_battle_start(&"Necrotic Bullet", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Necrotic Bullet", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Necrotic Bullet")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return "ERROR"

	var c := str(_chance[cardlvl - 1])
	var s := str(_necrosis_stacks[cardlvl - 1]).pad_decimals(0)
	return c + "% chance to inflict " + s + " [[NECROSIS_STACK]] on auto attack."
