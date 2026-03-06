class_name SerenityCorruptedLight
extends HeroUpgrade

@export var _conversion_percent: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Corrupted Light: Wrong card_lvl: ", card_lvl)
		return

	var conversion: float = float(_conversion_percent[card_lvl - 1])

	var _on_action_done := func(_target: Entity, action_type: Utils.ActionType, _action_id: StringName, value: float, _is_critical: bool) -> void:
		if action_type != Utils.ActionType.UTILITY_HEAL: return
		if value <= 0: return
		var damage_amount: float = value * (conversion / 100.0)
		if damage_amount <= 0: return
		var enemy: Entity = ctx.hero.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
		if enemy == null: return
		ctx.hero.direct_damage(enemy, damage_amount, Utils.ActionType.DAMAGE_MAGICAL, &"Corrupted Light")

	ctx.battle_callbacks.register_battle_start(&"Corrupted Light", func() -> void:
		if not ctx.hero.action_done.is_connected(_on_action_done):
			ctx.hero.action_done.connect(_on_action_done)
	)
	ctx.battle_callbacks.register_battle_end(&"Corrupted Light", func() -> void:
		if ctx.hero.action_done.is_connected(_on_action_done):
			ctx.hero.action_done.disconnect(_on_action_done)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		return "ERROR"

	var pct = str(_conversion_percent[cardlvl - 1]).pad_decimals(0)

	return "Convert " + pct + "% of heal done as [[MAGICAL_DAMAGE]]."
