class_name HealingCrossbow
extends HeroUpgrade

@export var _chance: Array[float]
@export var _heal_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Healing Crossbow: Wrong card_lvl: ", card_lvl)
		return
	
	var chance: float = _chance[card_lvl - 1]
	var heal: float = _heal_amount[card_lvl - 1]
	
	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Healing Crossbow"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(_cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id): return
		var target: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		if target == null: return
		ctx.hero.heal(target, heal, &"Healing Crossbow")
	
	ctx.battle_callbacks.register_battle_start(&"Healing Crossbow", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Healing Crossbow", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Healing Crossbow")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Healing Crossbow: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance[cardlvl - 1]) + "% chance to heal for " + str(_heal_amount[cardlvl - 1]) + " on auto-attack."
