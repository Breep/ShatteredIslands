class_name ColossusEvasiveGrowth
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _increase_max_hp: Array[float]


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var hp_gain: float = _increase_max_hp[card_lvl - 1]

	# Stat modifier: increase dodge vs physical damage
	var dodge_mod := StatModifier.new()
	dodge_mod.id = &"Evasive Growth"
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = _increase_dodge[card_lvl - 1]
	dodge_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(dodge_mod)

	# Action modifier: on dodge -> increase max HP
	var action_mod := ActionModifier.new()
	action_mod.id = &"Evasive Growth"
	action_mod.action_type = ActionModifier.ActionType.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		if ctx.hero and is_instance_valid(ctx.hero):
			ctx.hero.stats.health_max += hp_gain
	ctx.action_modifiers.register_modifier(action_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Evasive Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". Dodging an attack increase max hp by " + str(_increase_max_hp[cardlvl - 1]) + "."
