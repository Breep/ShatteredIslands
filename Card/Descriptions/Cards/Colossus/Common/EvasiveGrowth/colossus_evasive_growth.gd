class_name ColossusEvasiveGrowth
extends HeroUpgrade

@export var _increase_dodge: Array[float]
@export var _increase_sizes: Array[float]
@export var _dodge_reductions: Array[int]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Stone Skin: Wrong card_lvl: ", card_lvl)
		return
		
	var size_gain: float = _increase_sizes[card_lvl - 1]

	# Stat modifier: increase dodge vs physical damage
	var dodge_mod := StatModifier.new()
	dodge_mod.id = &"Evasive Growth"
	dodge_mod.stat_type = EntityStats.StatType.DODGE
	dodge_mod.action_type = Utils.ActionType.DAMAGE_PHYSICAL
	dodge_mod.calc_type = StatModifier.CalcType.ADD
	dodge_mod.value = _increase_dodge[card_lvl - 1]
	dodge_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(dodge_mod)

	# Action modifier: on dodge -> increase size, decrease dodge chance
	var action_mod := ActionModifier.new()
	action_mod.id = &"Evasive Growth"
	action_mod.action_type = Utils.ActionCategory.DODGE
	action_mod.is_one_time_effect = false
	action_mod.after_action_logic_callback = func(_cb_vars: Dictionary) -> void:
		if ctx.hero and is_instance_valid(ctx.hero):
			var mod2 := StatModifier.new()
			mod2.id = &"Evasive Growth"
			mod2.stat_type = EntityStats.StatType.DODGE
			mod2.action_type = Utils.ActionType.DAMAGE_PHYSICAL
			mod2.calc_type = StatModifier.CalcType.ADD
			mod2.value = _dodge_reductions[card_lvl - 1]
			ctx.stat_modifiers.register_modifier(mod2)
			
			var ratio_scaling: float = ctx.hero.scale[1] + (_increase_sizes[card_lvl - 1]/100)
			ctx.hero.scale = Vector3(ratio_scaling, ratio_scaling, ratio_scaling) 
			
	ctx.action_modifiers.register_modifier(action_mod)
	#TODO scale la défense en fonction de la size, faut il gérer dans le passif?

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Evasive Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase dodge by " + str(_increase_dodge[cardlvl - 1]) + ". Dodging an attack increase max hp by " + str(_increase_sizes[cardlvl - 1]) + "."
