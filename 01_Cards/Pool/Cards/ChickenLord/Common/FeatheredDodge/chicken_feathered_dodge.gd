class_name ChickenFeatheredDodge
extends CardEffect

@export var _dodge_increases: Array[float]
@export var _chicken_inheritances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var dodge_increase: float = _dodge_increases[card_lvl - 1]
	var chicken_inheritance: float = _chicken_inheritances[card_lvl - 1]
	
	var mod := StatModifier.new()
	mod.id = &"Feathered Dodge"
	mod.stat_type = EntityStats.StatType.DODGE
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = dodge_increase
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)
	
	ctx.hero.families_stats.chicken_lord.add_card_item(ctx.card_id, ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks, func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		var mod2 := StatModifier.new()
		mod2.calc_type = StatModifier.CalcType.ADD
		mod2.id = "ChickenFeatheredDodge_" + str(chicken.uid)
		mod2.stat_type = EntityStats.StatType.DODGE
		mod2.value = ctx.hero.stats.get_stat(EntityStats.StatType.DODGE) * chicken_inheritance/100
		chicken.stat_modifiers_registry.register_modifier(mod2)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.stat_modifiers.remove_modifier(EntityStats.StatType.DODGE, &"Feathered Dodge")
	ctx.hero.families_stats.chicken_lord.remove_card_items(ctx.card_id)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Feathered Dodge: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	#
	var c: String = str(_dodge_increases[cardlvl - 1]).pad_decimals(0)
	var s: String = str(_chicken_inheritances[cardlvl - 1]).pad_decimals(0)
	return "Ajoute " + c + " de [[DODGE]] au héros." + " Les poulets héritent de " + s + "% de l'esquive de l'invocateur."
