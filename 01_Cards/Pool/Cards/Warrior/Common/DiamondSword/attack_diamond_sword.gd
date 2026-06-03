class_name AttackDiamondSword
extends CardEffect

@export var _damage: Array[int]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Diamond Sword: Wrong card_lvl: ", card_lvl)
		return

	var mod := StatModifier.new()
	mod.id = &"Diamond Sword"
	mod.stat_type = EntityStats.StatType.AD
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _damage[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	ctx.stat_modifiers.register_modifier(mod)


func revert_card(ctx: CardContext, _card_lvl: int) -> void:
	ctx.stat_modifiers.remove_modifier(EntityStats.StatType.AD, &"Diamond Sword")


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Diamond Sword: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "[center]Increase turret damage by " + str(_damage[cardlvl - 1]) + ".[/center]"
