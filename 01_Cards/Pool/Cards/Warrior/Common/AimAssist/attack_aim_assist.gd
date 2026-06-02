class_name AttackAimAssist
extends CardEffect

@export var _bonus_ad_per_card: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aim Assist: Wrong card_lvl: ", card_lvl)
		return

	#var count: int = 0
	#if ctx.hero.hand:
		#count = ctx.hero.hand.get_unique_card_count(Family.Type.WARRIOR)
	#else:
		#push_warning("Aim Assist: deck is null")
#
	#var mod := StatModifier.new()
	#mod.id = &"Aim Assist"
	#mod.stat_type = EntityStats.StatType.AD
	#mod.calc_type = StatModifier.CalcType.ADD
	#mod.value = count * _bonus_ad_per_card[card_lvl - 1]
	#mod.tags = [StatModifier.TagType.CARD]
	#ctx.stat_modifiers.register_modifier(mod)


func revert_card(_ctx: CardContext, _card_lvl: int) -> void:
	pass


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Aim Assist: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	var val := str(_bonus_ad_per_card[cardlvl - 1]).pad_decimals(1)
	return "Increase your Attack Damage by " + val + " for each unique Attack card you possess."
