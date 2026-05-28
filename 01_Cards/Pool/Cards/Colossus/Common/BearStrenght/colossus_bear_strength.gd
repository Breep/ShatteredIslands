class_name ColossusBearStrength
extends HeroUpgrade

@export var _as_reduction: Array[float]
@export var _hp_to_ad_percents: Array[float]
@export var _scale_to_ad_percents: Array[float]

var _hp_to_ad_percent: float 
var _scale_to_ad_percent: float 

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	# Reduce attack speed
	var as_mod := StatModifier.new()
	as_mod.id = &"Bear Strength"
	as_mod.stat_type = EntityStats.StatType.AS
	as_mod.calc_type = StatModifier.CalcType.MULT
	as_mod.value = -(_as_reduction[card_lvl - 1] / 100.0)
	as_mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(as_mod)

	# Increase AD by % of max HP and size
	_hp_to_ad_percent = _hp_to_ad_percents[card_lvl - 1]
	_scale_to_ad_percent = _scale_to_ad_percents[card_lvl - 1]
	
	_update_ad_modifier(ctx.hero.stats.scale, ctx.hero.stats.health_max, ctx.hero)
	ctx.hero.stats.scale_changed.connect(func(scale: float) -> void:
		if not is_instance_valid(ctx.hero): return
		_update_ad_modifier(scale, ctx.hero.stats.health_max, ctx.hero)
	)
	
	ctx.hero.stats.health_max_changed.connect(func(hp_max: float) -> void:
		if not is_instance_valid(ctx.hero): return
		_update_ad_modifier(ctx.hero.stats.scale, hp_max, ctx.hero)
	)

func _update_ad_modifier(scale: float, hp_max: float, hero: Entity) -> void:
	var ad_mod := StatModifier.new()
	ad_mod.id = &"Bear Strength"
	ad_mod.stat_type = EntityStats.StatType.AD
	ad_mod.calc_type = StatModifier.CalcType.ADD
	ad_mod.value = hp_max * (_hp_to_ad_percent / 100.0) + (scale - 1) * (_scale_to_ad_percent)
	hero.stat_modifiers_registry.register_modifier(ad_mod)
	
func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Bear Strength: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Réduit la vitesse d'attaque de " + str(_as_reduction[cardlvl - 1]) + "%. Augmente l'AD de " + str(_hp_to_ad_percents[cardlvl - 1]) + "% des PV max et de " + str(_scale_to_ad_percents[cardlvl -1]) + "% du [[SCALE]]."
