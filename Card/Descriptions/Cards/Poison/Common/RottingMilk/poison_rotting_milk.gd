class_name PoisonRottingMilk
extends HeroUpgrade

@export var _chance: Array[float]
@export var _regen_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rotting Milk: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance[card_lvl - 1]
	var regen_stacks: int = _regen_stacks[card_lvl - 1]

	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Rotting Milk"
	modifier.tags = [ActionModifier.TagType.CARD]
	modifier.is_one_time_effect = false
	modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
		var stack_type: Stack.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
		if stack_type != Stack.Type.POISON: return
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			ctx.hero.inflict_condition_stacks(ctx.hero, regen_stacks, Stack.Type.REGEN, &"Rotting Milk")
	ctx.action_modifiers.register_modifier(modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Rotting Milk: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance[cardlvl - 1]) + "% of chance to gain " + str(_regen_stacks[cardlvl - 1]) + " [[REGEN_STACK]] when applying " \
			+ "[[POISON_STACK]]"
