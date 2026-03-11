class_name StormHammer
extends HeroUpgrade

@export var _chance_percent: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _chance_percent[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"Storm Hammer"
	aa_mod.tags = [AutoAttackModifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id): return
		var projectile: Projectile = cb_vars.get(AutoAttackModifier.VarType.PROJECTILE)
		if is_instance_valid(projectile):
			projectile.add_bounce(1)

	ctx.battle_callbacks.register_battle_start(&"Storm Hammer", func() -> void:
		ctx.auto_attack_modifiers.register_modifier(aa_mod)
	)
	ctx.battle_callbacks.register_battle_end(&"Storm Hammer", func() -> void:
		ctx.auto_attack_modifiers.unregister_modifier(&"Storm Hammer")
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Storm Hammer: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return str(_chance_percent[cardlvl - 1]) + "% chance for auto attack to add 1 bounce for auto attack"
