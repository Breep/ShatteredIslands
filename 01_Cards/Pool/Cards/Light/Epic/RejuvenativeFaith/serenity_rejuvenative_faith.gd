class_name SerenityRejuvenativeFaith
extends CardEffect

@export var _base_chance: Array[float]
@export var _base_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rejuvenative Faith: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]
	var amount: float = _base_amount[card_lvl - 1]

	var _on_interaction := func(_target: Entity, _source: Entity, action_type: Utils.ActionType, _action_id: StringName, value: float, _is_critical: bool) -> void:
		if action_type != Utils.ActionType.UTILITY_CLEANSE and action_type != Utils.ActionType.UTILITY_DISPELL:
			return
		if value <= 0: return
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			var regen_amount: float = value * amount
			if regen_amount > 0:
				ctx.hero.alterations.inflict_condition_stacks(ctx.hero, regen_amount, Alteration.Type.REGEN, &"Rejuvenative Faith")

	ctx.battle_callbacks.register_battle_start(&"Rejuvenative Faith", func() -> void:
		if not ctx.hero.action_received.is_connected(_on_interaction):
			ctx.hero.action_received.connect(_on_interaction)
	)
	ctx.battle_callbacks.register_battle_end(&"Rejuvenative Faith", func() -> void:
		if ctx.hero.action_received.is_connected(_on_interaction):
			ctx.hero.action_received.disconnect(_on_interaction)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Rejuvenative Faith: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var c = str(_base_chance[cardlvl - 1]).pad_decimals(0)
	var a = str(_base_amount[cardlvl - 1]).pad_decimals(1)
	return c + "% chance to apply " + a + " Regen for each stack dispelled or cleansed."
