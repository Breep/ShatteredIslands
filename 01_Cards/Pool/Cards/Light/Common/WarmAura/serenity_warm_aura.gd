class_name SerenityWarmAura
extends CardEffect

@export var _base_chance: Array[float]
@export var _base_cleanse_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Warm Aura: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]
	var amount: float = _base_cleanse_amount[card_lvl - 1]

	var _on_action_done := func(target: Entity, action_type: Utils.ActionType, _action_id: StringName, _value: float, _is_critical: bool) -> void:
		if action_type != Utils.ActionType.UTILITY_HEAL: return
		if target == null or not is_instance_valid(target) or target.is_dead(): return
		if Utils.is_randomize_modifier_active(chance):
			ctx.hero.alterations.cleanse(target, amount, &"Warm Aura")

	ctx.battle_callbacks.register_battle_start(&"Warm Aura", func() -> void:
		if not ctx.hero.action_done.is_connected(_on_action_done):
			ctx.hero.action_done.connect(_on_action_done)
	)
	ctx.battle_callbacks.register_battle_end(&"Warm Aura", func() -> void:
		if ctx.hero.action_done.is_connected(_on_action_done):
			ctx.hero.action_done.disconnect(_on_action_done)
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Warm Aura")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Warm Aura: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var c = str(_base_chance[cardlvl - 1]).pad_decimals(0)
	var a = str(_base_cleanse_amount[cardlvl - 1]).pad_decimals(0)

	return "On heal, " + c + "% chance to cleanse " + a + " on target."
