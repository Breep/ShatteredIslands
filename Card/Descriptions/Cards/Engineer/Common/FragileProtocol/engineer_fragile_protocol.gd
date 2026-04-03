class_name EngineerFragileProtocol
extends HeroUpgrade

@export var _heal_resistance: Array[float]
@export var _shield_power: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong card_lvl: ", card_lvl)
		return
	
	var mod_heal := StatModifier.new()
	mod_heal.value = _heal_resistance[card_lvl - 1]
	mod_heal.calc_type = StatModifier.CalcType.ADD
	mod_heal.stat_type = EntityStats.StatType.WEAKNESS
	mod_heal.action_type = Utils.ActionType.UTILITY_HEAL
	mod_heal.id = "Fragile Protocol"
	ctx.hero.stat_modifiers_registry.register_modifier(mod_heal)
	
	var mod_shield := StatModifier.new()
	mod_shield.value = _shield_power[card_lvl - 1]
	mod_shield.calc_type = StatModifier.CalcType.ADD
	mod_shield.stat_type = EntityStats.StatType.STRENGTH
	mod_shield.action_type = Utils.ActionType.STACK_SHIELD
	mod_shield.id = "Fragile Protocol"
	ctx.hero.stat_modifiers_registry.register_modifier(mod_shield)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var heal_reduction: String = str(_heal_resistance[cardlvl - 1]).pad_decimals(0)
	var shield_power: String = str(_shield_power[cardlvl - 1]).pad_decimals(0)
	return "Reduce heal power by " + heal_reduction + ". Gain " + shield_power + " [[SHIELD]] power."
