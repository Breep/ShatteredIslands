class_name FireKuiperBelt
extends CardEffect

@export var _shield_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong card_lvl: ", card_lvl)
		return

	var shield: int = int(_shield_amount[card_lvl - 1])

	var spell_modifier := ActionModifier.new()
	spell_modifier.action_type = Utils.ActionCategory.SPELL
	spell_modifier.id = &"Kuiper Belt"
	spell_modifier.is_one_time_effect = false
	spell_modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.SPELL_TYPE) != Spell.Type.METEOR: return
		if shield > 0:
			ctx.hero.alterations.inflict_condition_stacks(ctx.hero, shield, Alteration.Type.SHIELD, &"Kuiper Belt")
	ctx.action_modifiers.register_modifier(spell_modifier)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	var spell_modifier := ActionModifier.new()
	spell_modifier.action_type = Utils.ActionCategory.SPELL
	spell_modifier.id = &"Kuiper Belt"
	ctx.action_modifiers.unregister_modifier(spell_modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Gagne " + str(_shield_amount[cardlvl - 1]) + " [[SHIELD]] par [[METEOR]] invoqué."
