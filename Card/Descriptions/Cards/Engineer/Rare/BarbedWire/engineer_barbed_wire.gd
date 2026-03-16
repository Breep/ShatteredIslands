class_name EngineerBarbedWire
extends HeroUpgrade

@export var _thorns: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Barbed Wire: Wrong card_lvl: ", card_lvl)
		return
	
	var mod_thorn := StatModifier.new()
	mod_thorn.value = _thorns[card_lvl - 1]
	mod_thorn.calc_type = StatModifier.CalcType.ADD
	mod_thorn.stat_type = EntityStats.StatType.THORN
	mod_thorn.id = "Barbed Wire"
	ctx.hero.stat_modifiers_registry.register_modifier(mod_thorn)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Barbed Wire: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var thorn: String = str(_thorns[cardlvl - 1]).pad_decimals(0)
	return "Gain " + thorn + " thorn while having shield"
