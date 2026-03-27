class_name FireApocalypse
extends HeroUpgrade

@export var _meteor_bonus: Array[int]
@export var _proc_chance: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		printerr("Apocalypse: Wrong card_lvl: ", card_lvl)
		return
	
	var meteor_bonus: int = _meteor_bonus[card_lvl -1]
	var proc_chance: float = _proc_chance[card_lvl - 1]

	ctx.hero.families_stats.ardent_celestial.meteor_on_cast_callbacks.append(func(_cb_vars: Dictionary) -> void:
		if Utils.is_randomize_modifier_active(proc_chance, ctx.hero.battle_id, "Apocalypse"):
			recast(ctx, _meteor_bonus[card_lvl - 1])
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.LEGENDARY]:
		return "ERROR"

	return "Each meteor has " + str(_proc_chance[cardlvl - 1]) + "% chance to cast " + str(_meteor_bonus[cardlvl - 1]) + "other meteors." 

func recast(ctx: CardContext, remaining_meteor: int) -> void:
	if remaining_meteor <= 0:
		return
	var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
	if not is_instance_valid(target): return
	var _ardent_celestial_stats: FamilyArdentCelestialStats = ctx.hero.families_stats.ardent_celestial
	var families_level: Dictionary[Family.Type, int] = ctx.hero.get_families_level()
	var ardent_celestial_level: int = families_level[Family.Type.ARDENT_CELESTIAL]
	ctx.hero.cast_spell(target, Spell.Type.METEOR,{ 
		Spell.MeteorModifier.DAMAGE_PERCENT: _ardent_celestial_stats.meteor_damage_percent[ardent_celestial_level],
		Spell.MeteorModifier.RADIUS: _ardent_celestial_stats.meteor_radius,
		Spell.MeteorModifier.ON_HIT_CALLBACKS: _ardent_celestial_stats.meteor_on_hit_callbacks
		})
	recast(ctx, remaining_meteor - 1)
