class_name ColossusStoneSkin
extends HeroUpgrade

@export var _base_thorn_values: Array[float]
@export var _bonus_thorn_factors: Array[float]


func apply_card(ctx: CardContext, card_lvl: int) -> void:
	var base_thorn: float = _base_thorn_values[card_lvl - 1]
	var bonus_thorn_factor: float = _bonus_thorn_factors[card_lvl - 1]
	
	#TODO Il faut rendre le thorn dynamique en fonction du size increase, y'a pas encore de cb sur un action modifier de type size increase
	var mod := StatModifier.new()
	mod.id = &"Stone Skin"
	mod.stat_type = EntityStats.StatType.THORN
	mod.calc_type = StatModifier.CalcType.ADD
	var size_increase: float = ctx.hero.scale[1] - 1
	mod.value = base_thorn + size_increase * bonus_thorn_factor
	ctx.hero.stat_modifiers_registry.register_modifier(mod)

func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.COMMON]:
		printerr("Stone Skin: Wrong cardlvl: ", cardlvl)
		return "ERROR"

	return "Increase thorn by " + str(_base_thorn_values[cardlvl - 1]) + " + " + str(_bonus_thorn_factors[cardlvl - 1]) + "* hero's size."
