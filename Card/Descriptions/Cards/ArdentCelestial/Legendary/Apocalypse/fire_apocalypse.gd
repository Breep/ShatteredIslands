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
		var ardent_stats: FamilyArdentCelestialStats = ctx.hero.families_stats.ardent_celestial
		var ardent_level: int = ctx.hero.get_families_level()[Family.Type.ARDENT_CELESTIAL]
		for i in meteor_bonus:
			if Utils.is_randomize_modifier_active(_proc_chance[card_lvl - 1]):
				var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
				if not is_instance_valid(target): break
				ctx.hero.cast_spell(target, Spell.Type.METEOR, {
					Spell.MeteorModifier.DAMAGE_PERCENT: ardent_stats.meteor_damage_percent[ardent_level],
					Spell.MeteorModifier.RADIUS: ardent_stats.meteor_radius,
					Spell.MeteorModifier.ON_HIT_CALLBACKS: ardent_stats.meteor_on_hit_callbacks
			})
		_is_recasting = false
	ctx.action_modifiers.register_modifier(spell_modifier)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"
	return "toto"
