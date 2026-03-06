class_name DefenseEvasiveBarrier
extends HeroUpgrade

@export var _dodge_increase: Array[float]
@export var _shield_gain: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Evasive Barrier: Wrong card_lvl: ", card_lvl)
		return

	var dodge_value: float = _dodge_increase[card_lvl - 1]
	var shield_amount: float = _shield_gain[card_lvl - 1]

	# Stat modifier: +dodge
	var mod := StatModifier.new()
	mod.id = &"Evasive Barrier"
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = dodge_value
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)

	# Action modifier: on dodge → gain shield
	var action_mod := ActionModifier.new()
	action_mod.id = &"Evasive Barrier"
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero):
			return
		ctx.hero.inflict_condition_stacks(ctx.hero, shield_amount, Stack.Type.SHIELD, &"Evasive Barrier")
	ctx.action_modifiers.register_modifier(action_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Evasive Barrier: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase dodge by " + str(_dodge_increase[cardlvl - 1]) + ". Gain " + str(_shield_gain[cardlvl - 1]) + " shield on dodge."
