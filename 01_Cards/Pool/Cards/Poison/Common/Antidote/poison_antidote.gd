class_name PoisonAntidote
extends CardEffect

@export var _damage_deacrease: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Antidote: Wrong card_lvl: ", card_lvl)
		return

	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _damage_deacrease[card_lvl - 1]
	mod.stat_type = EntityStats.StatType.POISON_RESIST
	mod.id = &"Antidote"
	ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Antidote: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Decrease [[POISON_DAMAGE]] received by " + str(_damage_deacrease[cardlvl - 1]) + "%"
