class_name SerenityRadiantOverflow
extends HeroUpgrade

@export var _ratio: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		printerr("Radiant Overflow: Wrong card_lvl: ", card_lvl)
		return

	var ratio: float = _ratio[card_lvl - 1]

	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.HEAL
	modifier.id = &"Radiant Overflow"
	modifier.is_one_time_effect = false
	modifier.before_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.TARGET): return
		if not cb_vars.has(ActionModifier.VarType.HEAL_AMOUNT): return
		var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		var regen_stacks: float = target.conditions.regen_stacks
		if regen_stacks <= 0: return
		cb_vars[ActionModifier.VarType.HEAL_AMOUNT] *= (1.0 + regen_stacks * ratio)
	ctx.action_modifiers.register_modifier(modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.RARE]:
		return "ERROR"

	var r = str(_ratio[cardlvl - 1] * 100.0).pad_decimals(1)

	return "Heals are " + r + "% more effective for each [[REGEN_STACK]] on target."
