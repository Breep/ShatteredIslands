class_name ArdentCelestialQuasar
extends CardEffect

@export var _hp_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quasar: Wrong card_lvl: ", card_lvl)
		return

	var hp_amount: int = int(_hp_amount[card_lvl - 1])

	var mod := StatModifier.new()
	mod.id = &"Quasar"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.tags = [StatModifier.TagType.CARD]
	
	
	var spell_modifier := ActionModifier.new()
	spell_modifier.action_type = Utils.ActionCategory.SPELL
	spell_modifier.id = &"Quasar"
	spell_modifier.is_one_time_effect = false
	spell_modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.SPELL_TYPE) != Spell.Type.METEOR: return
		mod.value += hp_amount
		ctx.stat_modifiers.register_modifier(mod)
		
	ctx.action_modifiers.register_modifier(spell_modifier)



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Quasar: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Augmente les PV max de " + str(_hp_amount[cardlvl - 1]) + " par [[METEOR]] invoqué."
