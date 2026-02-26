class_name AttackRustyDagger
extends HeroUpgrade

@export var _chance: Array[float]
@export var _poison_stacks: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rusty Dagger: Wrong card_lvl: ", card_lvl)
		return

	var _chance_val: float = _chance[card_lvl - 1]
	var _stacks: float = _poison_stacks[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Rusty Dagger"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_attack_logic_callback = func(_cb_vars: Dictionary) -> void:
		pass # TODO: rework with direct callback

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
