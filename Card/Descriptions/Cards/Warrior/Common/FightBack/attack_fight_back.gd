class_name AttackFightBack
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _increase_attack_damage: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fight Back: Wrong card_lvl: ", card_lvl)
		return

	var dodge_value: float = _increase_dodge[card_lvl - 1]
	var ad_per_dodge: float = _increase_attack_damage[card_lvl - 1]

	# Stat modifier: +dodge
	var dodge_mod := StatModifier.new()
	dodge_mod.id = &"Fight Back"
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = dodge_value
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	ctx.stat_modifiers.register_modifier(dodge_mod)

	# Action modifier: on dodge → accumulate AD
	var state := {&"dodge_count": 0}

	var action_mod := ActionModifier.new()
	action_mod.id = &"Fight Back"
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		state[&"dodge_count"] += 1
		var ad_mod := StatModifier.new()
		ad_mod.id = &"Fight Back"
		ad_mod.stat_type = EntityStats.StatType.AD
		ad_mod.calc_type = StatModifier.CalcType.ADD
		ad_mod.value = state[&"dodge_count"] * ad_per_dodge
		ad_mod.tags = [StatModifier.TagType.CARD]
		ctx.stat_modifiers.register_modifier(ad_mod)
	ctx.action_modifiers.register_modifier(action_mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fight Back: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". On dodge, increase attack damage by " + str(_increase_attack_damage[cardlvl - 1]) + "."
