class_name AttackSurgicalKnife
extends CardEffect

@export var _chance: Array[float]
@export var _cleanse_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Surgical Knife: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance[card_lvl - 1]
	var amount: float = _cleanse_amount[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Surgical Knife"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			return
		ctx.hero.alterations.cleanse(ctx.hero, amount, &"Surgical Knife")

	ctx.battle_callbacks.register_battle_start(&"Surgical Knife", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Surgical Knife")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Surgical Knife: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance[cardlvl - 1]) + "% chance to cleanse " + str(_cleanse_amount[cardlvl - 1]) + " self negative stack(s) on attack."
