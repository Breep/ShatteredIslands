class_name AttackRussianRoulette
extends HeroUpgrade

@export var _min_percent: Array[int]
@export var _max_percent: Array[int]
@export var _rarity: Card.Rarity = Card.Rarity.LEGENDARY


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Russian Roulette: Wrong card_lvl: ", card_lvl)
		return

	var _min_p: int = _min_percent[card_lvl - 1]
	var _max_p: int = _max_percent[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Russian Roulette"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.on_attack_logic_callback = func(_cb_vars: Dictionary) -> void:
		pass # TODO: rework with direct callback (damage multiplier)

	ctx.battle_callbacks.register_battle_start(&"Russian Roulette", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Russian Roulette", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Russian Roulette")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		return "ERROR"

	var min_p := str(_min_percent[cardlvl - 1]).pad_decimals(0)
	var max_p := str(_max_percent[cardlvl - 1]).pad_decimals(0)
	return "Auto Attack deals between " + min_p + " - " + max_p + "% damage."
