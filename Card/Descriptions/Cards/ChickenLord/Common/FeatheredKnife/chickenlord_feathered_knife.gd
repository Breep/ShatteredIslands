class_name ChickenLordFeatheredKnife
extends HeroUpgrade

@export var _spawn_chances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var chance: float = _spawn_chances[card_lvl - 1]
	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = "Feathered Knife"
	aa_mod.is_one_time_effect = false
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id): return
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if not is_instance_valid(target) or target.is_queued_for_deletion(): return
		ctx.hero.summon_entity(Entity.EntityType.CHICKEN_EGG, SpawnLocationConfig.create_entity_relative(target, 1), {})
	ctx.hero.auto_attack_modifier_registry.register_modifier(aa_mod)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Feathered Knife: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var c: String = str(_spawn_chances[cardlvl - 1]).pad_decimals(0)
	return "En auto-attaque, " + c + "% de chance de pondre un oeuf."
