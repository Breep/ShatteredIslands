class_name ColossusAncientCollector
extends HeroUpgrade

@export var _amount_per_card: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var amount: float = _amount_per_card[card_lvl - 1]

	var mod := StatModifier.new()
	mod.id = &"The Ancient Collector"
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.calc_type = StatModifier.CalcType.ADD
	mod.tags = [StatModifier.TagType.CARD]

	# Count unique Colossus/Life cards in deck
	if ctx.hero.deck:
		var colossus_count: int = ctx.hero.deck.get_unique_card_count(Family.Type.COLOSSUS)
		mod.value = colossus_count * amount
	else:
		push_warning("Ancient Collector: deck is null")

	ctx.stat_modifiers.register_modifier(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("The Ancient Collector: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var amount_str = str(_amount_per_card[cardlvl - 1]).pad_decimals(0)

	return "Gain " + amount_str + " Max Health for each unique Colossus card you have."
