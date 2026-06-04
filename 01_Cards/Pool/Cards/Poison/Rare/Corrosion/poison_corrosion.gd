class_name PoisonCorrosion
extends CardEffect

@export var _buff_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Corrosion: Wrong card_lvl: ", card_lvl)
		return

	var buff_stacks: int = _buff_stacks[card_lvl - 1]

	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Corrosion"
	modifier.tags = [ActionModifier.TagType.CARD]
	modifier.is_one_time_effect = false
	modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
		if not cb_vars.has(ActionModifier.VarType.TARGET): return
		var stack_type: Alteration.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
		var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
		if stack_type != Alteration.Type.POISON: return
		ctx.hero.alterations.dispell(target, buff_stacks, &"Corrosion")
	ctx.action_modifiers.register_modifier(modifier)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Corrosion"
	ctx.action_modifiers.unregister_modifier(modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Corrosion: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Each time applying [[POISON_STACK]], remove " + str(_buff_stacks[cardlvl - 1]) + " [[BUF_STACKS]] on the target"
