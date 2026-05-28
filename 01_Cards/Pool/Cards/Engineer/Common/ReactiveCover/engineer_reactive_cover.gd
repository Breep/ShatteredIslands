class_name EngineerReactiveCover
extends CardEffect

@export var _base_chance: Array[float]
@export var _base_shield_amount: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reactive Cover: Wrong card_lvl: ", card_lvl)
		return

	var chance: float = _base_chance[card_lvl - 1]
	var shield_amount: float = _base_shield_amount[card_lvl - 1]

	var _on_damage_taken := func(damage: float, _damage_type: Utils.ActionType, _is_crit: bool, _is_blocked: bool) -> void:
		if damage <= 0:
			return
		if Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			ctx.hero.alterations.inflict_condition_stacks(ctx.hero, shield_amount, Alteration.Type.SHIELD, &"Reactive Cover")

	ctx.battle_callbacks.register_battle_start(&"Reactive Cover", func() -> void:
		if not ctx.hero.damage_taken.is_connected(_on_damage_taken):
			ctx.hero.damage_taken.connect(_on_damage_taken)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Reactive Cover: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "En recevant des dégâts, " + str(_base_chance[cardlvl - 1]) + "% de chance de gagner " + str(_base_shield_amount[cardlvl - 1]) + " [[SHIELD]]."
