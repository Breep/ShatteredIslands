class_name StormHammer
extends HeroUpgrade

@export var _chance_percent: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.EPIC


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong card_lvl: ", card_lvl)
		return

	var _chance: float = _chance_percent[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Storm Hammer"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_attack_logic_callback = func(_cb_vars: Dictionary) -> void:
		pass # TODO: rework with direct callback (bouncing projectile)

	ctx.battle_callbacks.register_battle_start(&"Storm Hammer", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Storm Hammer", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Storm Hammer")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance_percent[cardlvl - 1]) + "% chance for auto attack to bounce on another target."
