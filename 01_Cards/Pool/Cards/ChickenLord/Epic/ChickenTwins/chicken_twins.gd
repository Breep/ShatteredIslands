class_name ChickenTwins
extends CardEffect

@export var _chance: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var chance: float = _chance[card_lvl - 1]

	var mod := HatchModifier.new()
	mod.id = &"Chicken Twins"
	mod.is_one_time_effect = false
	mod.before_hatch_callback = func(vars: Dictionary) -> void:
		if not Utils.is_randomize_modifier_active(chance, ctx.hero.battle_id):
			return
		vars[HatchModifier.VarType.SPAWN_COUNT] += 1
	ctx.hero.families_stats.chicken_lord.hatch_modifiers.append(mod)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Twins: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Donne " + str(_chance[cardlvl - 1]) + "% de chance d'invoquer des poulets jumeaux."
