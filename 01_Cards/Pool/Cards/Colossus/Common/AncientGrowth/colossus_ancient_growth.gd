class_name ColossusAncientGrowth
extends CardEffect

@export var _size_increase: Array[float]
@export var _period: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var size_increase: float = _size_increase[card_lvl - 1]
	var period: float = _period[card_lvl - 1]
	
	var state := {&"stacks": 0}
	var mod3 := StatModifier.new()
	mod3.id = &"Ancient Growth"
	mod3.stat_type = EntityStats.StatType.SCALE
	mod3.calc_type = StatModifier.CalcType.ADD
	mod3.value = 0.0

	ctx.battle_callbacks.register_periodic(&"Ancient Growth", period, func() -> void:
		state[&"stacks"] += 1
		mod3.value = state[&"stacks"] * (size_increase / 100)
		ctx.stat_modifiers.register_modifier(mod3)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Ancient Growth: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var s: String = str(_size_increase[cardlvl - 1]).pad_decimals(0)
	var p: String = str(_period[cardlvl - 1]).pad_decimals(0)
	return "Augmente le [[SCALE]] de " + s + "% toutes les " + p + "s."
