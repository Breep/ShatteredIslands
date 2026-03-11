class_name FireTitansProtection
extends HeroUpgrade

@export var _hp_amount: Array[float]
@export var _rarity: Card.Rarity = Card.Rarity.COMMON

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titans Protection: Wrong card_lvl: ", card_lvl)
		return

	var hp_amount: float = _hp_amount[card_lvl - 1]
	var ardent_celestial_stats: FamilyArdentCelestialStats = ctx.hero.families_stats.ardent_celestial

	ardent_celestial_stats.meteor_modifiers.append(func(_cb_vars: Dictionary) -> void:
		if ctx.hero == null or not is_instance_valid(ctx.hero): return
		if hp_amount > 0:
			ardent_celestial_stats.titans_protection_accumulated_hp += hp_amount
			var mod := StatModifier.new()
			mod.id = &"Fire Titan Protection"
			mod.stat_type = EntityStats.StatType.HEALTH_MAX
			mod.calc_type = StatModifier.CalcType.ADD
			mod.value = ardent_celestial_stats.titans_protection_accumulated_hp
			mod.tags = [StatModifier.TagType.CARD]
			ctx.hero.stat_modifiers_registry.register_modifier(mod)
	)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Titans Protection: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase max HP for this battle by " + str(_hp_amount[cardlvl - 1]) + " per [[METEOR]] spawn."
