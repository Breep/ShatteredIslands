class_name PoisonHotPot
extends HeroUpgrade

@export var _chance: Array[float]
@export var _ignite_stacks: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Hot Pot: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance[card_lvl - 1]
	var ignite_stacks: int = _ignite_stacks[card_lvl - 1]

	var modifier := ActionModifier.new()
	modifier.action_type = Utils.ActionCategory.STACK
	modifier.id = &"Hot Pot"
	modifier.tags = [ActionModifier.TagType.CARD]
	modifier.is_one_time_effect = false
	modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(ActionModifier.VarType.STACK_TYPE): return
		if not cb_vars.has(ActionModifier.VarType.TARGET): return
		var stack_type: Alteration.Type = cb_vars[ActionModifier.VarType.STACK_TYPE]
		var target: Entity = cb_vars[ActionModifier.VarType.TARGET]
		if stack_type != Alteration.Type.POISON: return
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			ctx.hero.inflict_condition_stacks(target, ignite_stacks, Alteration.Type.IGNITE, &"Hot Pot")
	ctx.action_modifiers.register_modifier(modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Hot Pot: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance[cardlvl - 1]) + "% of chance to gain " + str(_ignite_stacks[cardlvl - 1]) + " [[IGNITE_STACK]] when applying " \
			+ "[[POISON_STACK]]"
