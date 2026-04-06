class_name EngineerShieldRush
extends HeroUpgrade

@export var _shield_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Rush: Wrong card_lvl: ", card_lvl)
		return

	var amount: int = int(_shield_amount[card_lvl - 1])

	ctx.battle_callbacks.register_battle_start(&"Shield Rush", func() -> void:
		if ctx.hero != null and is_instance_valid(ctx.hero):
			var allies: Array[Entity] = ctx.hero.target_module.get_targets(TargetModule.MultipleTargettingStrategy.ALLIES)
			var shield_distribution: Array[float] = Utils.get_randf_distribution(amount, allies.size(), ctx.hero.battle_id)
			for i in allies.size():
				var shield_gain: float = shield_distribution[i]
				ctx.hero.inflict_condition_stacks(allies[i], shield_gain, Stack.Type.SHIELD, &"Shield Rush")
				ShieldVfxSpawner.spawn_on(allies[i])
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Shield Rush: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Au début du combat, [[SHIELD]] de " + str(_shield_amount[cardlvl - 1]) + "."
