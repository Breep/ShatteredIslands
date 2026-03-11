class_name AttackProtectoSpear
extends HeroUpgrade

@export var _base_chance: Array[float]
@export var _base_shield_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protecto'Spear: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]
	var shield_amount: float = _base_shield_amount[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Protecto'Spear"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			ctx.hero.inflict_condition_stacks(ctx.hero, shield_amount, Stack.Type.SHIELD, &"Protecto'Spear")

	ctx.battle_callbacks.register_battle_start(&"Protecto'Spear", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Protecto'Spear", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Protecto'Spear")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Protecto'Spear: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_base_chance[cardlvl - 1]) + "% chance to gain " + str(_base_shield_amount[cardlvl - 1]) + " shield on auto-attack"
