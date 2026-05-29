class_name LightLifeSpring
extends CardEffect

@export var _regen_amount: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Life Spring: Wrong card_lvl: ", card_lvl)
		return

	var regen: float = _regen_amount[card_lvl - 1]
	var period: float = _period[card_lvl - 1]

	ctx.battle_callbacks.register_periodic(&"Life Spring", period, func() -> void:
		var target: Entity = ctx.hero.target.get_target(TargetComponent.TargettingStrategy.LOWEST_HP_ALLY_INCLUDING_SELF)
		if target == null: return
		ctx.hero.alterations.inflict_condition_stacks(target, regen, Alteration.Type.REGEN, &"Life Spring")
	)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.battle_callbacks.unregister_all(&"Life Spring")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Life Spring: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Apply " + str(_regen_amount[cardlvl - 1]) + " regen to the lowest hp ally hero every " + str(_period[cardlvl - 1]) + " sec"
