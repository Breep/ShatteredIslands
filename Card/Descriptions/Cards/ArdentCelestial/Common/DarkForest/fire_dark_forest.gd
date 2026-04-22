class_name FireDarkForest
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _ignite_stacks: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Dark Forest: Wrong card_lvl: ", card_lvl)
		return

	var dodge_val: float = _increase_dodge[card_lvl - 1]
	var ignite: int = int(_ignite_stacks[card_lvl - 1])

	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = dodge_val
	mod.stat_type = EntityStats.StatType.DODGE
	mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	mod.id = &"Dark Forest"
	ctx.stat_modifiers.register_modifier(mod)

	var action_mod := ActionModifier.new()
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.id = &"Dark Forest"
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		var target: Entity = cb_vars.get(ActionModifier.VarType.TARGET)
		if target != null:
			ctx.hero.inflict_condition_stacks(target, ignite, Alteration.Type.IGNITE, &"Dark Forest")
	ctx.action_modifiers.register_modifier(action_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Dark Forest: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente le [[DODGE]] de " + str(_increase_dodge[cardlvl - 1]) + ". En cas de [[DODGE]], inflige " + str(_ignite_stacks[cardlvl - 1]) + " stack d'[[IGNITE]] à l'attaquant."
