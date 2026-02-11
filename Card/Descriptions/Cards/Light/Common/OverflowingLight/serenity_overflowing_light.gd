class_name SerenityOverflowingLight
extends HeroUpgrade

@export var _base_shield_percent: Array[float]

@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Overflowing Light: Wrong card_lvl: ", card_lvl)
		return

	var shield_percent: float = _base_shield_percent[card_lvl - 1]

	var _on_overhealed := func(_entity_ref: Entity, target: Entity, overheal_amount: float) -> void:
		if overheal_amount <= 0: return
		if target == null or not is_instance_valid(target) or target.is_dead: return
		var shield_amount: float = overheal_amount * (shield_percent / 100.0)
		if shield_amount > 0:
			ctx.hero.inflict_condition_stacks(target, shield_amount, Utils.StackType.SHIELD, &"Overflowing Light")

	ctx.battle_callbacks.register_battle_start(&"Overflowing Light", func() -> void:
		if not ctx.hero.action_overhealed.is_connected(_on_overhealed):
			ctx.hero.action_overhealed.connect(_on_overhealed)
	)
	ctx.battle_callbacks.register_battle_end(&"Overflowing Light", func() -> void:
		if ctx.hero.action_overhealed.is_connected(_on_overhealed):
			ctx.hero.action_overhealed.disconnect(_on_overhealed)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Overflowing Light: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var pct = str(_base_shield_percent[cardlvl - 1]).pad_decimals(0)

	return pct + "% overheal convert into shield."
