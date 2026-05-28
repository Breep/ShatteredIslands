class_name FireCosmicBolt
extends HeroUpgrade

@export var _stacks: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong card_lvl: ", card_lvl)
		return
		
	var mod := AutoAttackModifier.new()
	mod.id = &"CosmicBolt"
	mod.is_one_time_effect = false
	mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if target == null or target.is_queued_for_deletion(): return
		ctx.hero.alterations.inflict_condition_stacks(target, _stacks[card_lvl - 1], Alteration.Type.IGNITE, "CosmicBolt")
	ctx.hero.auto_attack_modifier_registry.register_modifier(mod)



func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Cosmic Bolt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Chaque auto-attaque applique " + str(_stacks[cardlvl - 1]) + " stacks d'[[IGNITE]] à la cible."
