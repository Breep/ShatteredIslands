class_name SerenityDivineRegenerator
extends CardEffect

@export var _bonus_duration: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Divine Regenerator: Wrong card_lvl: ", card_lvl)
		return

	var bonus: int = _bonus_duration[card_lvl - 1]

	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Divine Regenerator"
	modifier.is_one_time_effect = false
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
		if not cb_vars.has(ActionModifier.VarType.DURATION): return
		if cb_vars[ActionModifier.VarType.STACK_TYPE] != Alteration.Type.REGEN: return
		cb_vars[ActionModifier.VarType.DURATION] += bonus
	ctx.action_modifiers.register_modifier(modifier)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Divine Regenerator"
	ctx.action_modifiers.unregister_modifier(modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"

	var d = str(_bonus_duration[cardlvl - 1])

	return "Add " + d + "s to all [[REGEN_STACK]] duration."
