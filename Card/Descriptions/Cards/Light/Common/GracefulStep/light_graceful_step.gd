class_name LightGracefulStep
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _amount_regen: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Graceful Step: Wrong card_lvl: ", card_lvl)
		return

	var dodge_val: float = _increase_dodge[card_lvl - 1]
	var regen_val: float = _amount_regen[card_lvl - 1]

	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = dodge_val
	mod.stat_type = EntityStats.StatType.DODGE
	mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	mod.id = &"Graceful Step"
	ctx.stat_modifiers.register_modifier(mod)

	var action_mod := ActionModifier.new()
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.id = &"Graceful Step"
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		if target != null:
			ctx.hero.inflict_condition_stacks(target, regen_val, Stack.Type.REGEN, &"Graceful Step")
	ctx.action_modifiers.register_modifier(action_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Graceful Step: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) +". On dodge, Apply" + str(_amount_regen[cardlvl - 1]) + "regen on ally"
