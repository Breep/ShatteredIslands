class_name ColossusStoneSkin
extends HeroUpgrade

@export var _base_thorn_values: Array[float]
@export var _bonus_thorn_factors: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Stone Skin: Wrong card_lvl: ", card_lvl)
		return
	
	var base_thorn: float = _base_thorn_values[card_lvl - 1]
	
	var mod := StatModifier.new()
	mod.id = &"Stone Skin"
	mod.stat_type = EntityStats.StatType.THORN
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = base_thorn
	ctx.hero.stat_modifiers_registry.register_modifier(mod)
	
	_apply_thorn_scaling(ctx.hero, card_lvl)
	var _on_scale_changed: Callable
	_on_scale_changed = func(scale: float) -> void:
		if is_instance_valid(ctx.hero) and not ctx.hero.is_queued_for_deletion():
			_apply_thorn_scaling(ctx.hero, card_lvl)
		
	if not ctx.hero.stats.scale_changed.is_connected(_on_scale_changed):
		ctx.hero.stats.scale_changed.connect(_on_scale_changed)
		


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Stone Skin: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase thorn by " + str(_base_thorn_values[cardlvl - 1]) + " + " + str(_bonus_thorn_factors[cardlvl - 1]) + "* hero's [[SCALE]]."


func _apply_thorn_scaling(hero: Entity, card_lvl: int) -> void:
	var bonus_thorn_factor: float = _bonus_thorn_factors[card_lvl - 1]
	var mod2 := StatModifier.new()
	mod2.id = &"Stone Skin dynamic"
	mod2.stat_type = EntityStats.StatType.THORN
	mod2.calc_type = StatModifier.CalcType.ADD
	mod2.value = bonus_thorn_factor * (hero.stats.scale - 1) * 100
	hero.stat_modifiers_registry.register_modifier(mod2)
