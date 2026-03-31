class_name ArdentCelestialDiamondSkin
extends HeroUpgrade

@export var _magical_resistances: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong card_lvl: ", card_lvl)
		return

	var magical_resistance: float = _magical_resistances[card_lvl - 1]

	var mod := StatModifier.new()
	mod.id = &"Diamond Skin"
	mod.stat_type = EntityStats.StatType.RESISTANCE
	mod.action_type = Utils.ActionType.DAMAGE_MAGICAL
	mod.calc_type = StatModifier.CalcType.ADD
	mod.tags = [StatModifier.TagType.CARD]
	mod.value = magical_resistance
	ctx.hero.stat_modifiers_registry.register_modifier(mod)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Kuiper Belt: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Hero gains " + str(_magical_resistances[cardlvl - 1]) + " [[MAGICAL_DAMAGE]] resistance."
