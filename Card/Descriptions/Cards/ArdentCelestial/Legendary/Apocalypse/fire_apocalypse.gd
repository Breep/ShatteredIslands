class_name FireApocalypse
extends HeroUpgrade

@export var _meteor_bonus: Array[int]
@export var _proc_chance: Array[float]

var _is_recasting: bool = false

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Apocalypse: Wrong card_lvl: ", card_lvl)
		return

	var meteor_bonus: int = _meteor_bonus[card_lvl - 1]

	var spell_modifier := ActionModifier.new()
	spell_modifier.action_type = Utils.ActionCategory.SPELL
	spell_modifier.id = &"Apocalypse"
	spell_modifier.is_one_time_effect = false
	spell_modifier.after_action_logic_callback = func(cb_vars: Dictionary) -> void:
		if cb_vars.get(ActionModifier.VarType.SPELL_TYPE) != Spell.Type.METEOR: return
		if _is_recasting: return
		_is_recasting = true
		for i in meteor_bonus:
			var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
			if not is_instance_valid(target): break
			ctx.hero.cast_spell(target, Spell.Type.METEOR)
		_is_recasting = false
	ctx.action_modifiers.register_modifier(spell_modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"
	return "toto"
