class_name ChickenLordChickenVitality
extends CardEffect

@export var _hp_bonuses: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chicken Vitality: Wrong card_lvl: ", card_lvl)
		return

	var hp_bonus: float = _hp_bonuses[card_lvl - 1]

	ctx.hero.families_stats.chicken_lord.on_chicken_spawned_callbacks.append(func(cb_vars: Dictionary) -> void:
		var chicken: Chicken = cb_vars.get(FamilyChickenLordStats.CbVars.SELF_CHICKEN)
		if not is_instance_valid(chicken): return
		var mod := StatModifier.new()
		mod.calc_type = StatModifier.CalcType.ADD
		mod.id = &"ChickenVitality"
		mod.stat_type = EntityStats.StatType.HEALTH_MAX
		mod.value = hp_bonus
		chicken.stat_modifiers_registry.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Chicken Vitality: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var hp: String = str(_hp_bonuses[cardlvl - 1]).pad_decimals(0)
	return "Les poulets gagnent " + hp + " HP supplémentaires à la naissance."
