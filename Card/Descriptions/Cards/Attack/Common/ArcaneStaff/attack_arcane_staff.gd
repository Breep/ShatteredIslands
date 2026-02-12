class_name AttackArcaneStaff
extends HeroUpgrade

@export var _chance_percent: Array[float]
@export var _mana_gain: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Arcane Staff: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance_percent[card_lvl - 1]
	var mana: float = _mana_gain[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Arcane Staff"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_hit_logic_callback = func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance):
			return
		if mana > 0:
			ctx.hero.stats.mana += mana

	ctx.battle_callbacks.register_battle_start(&"Arcane Staff", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Arcane Staff", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Arcane Staff")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Arcane Staff: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance_percent[cardlvl - 1]) + "% chance to regen " + str(_mana_gain[cardlvl - 1]) + " mana on hit."
