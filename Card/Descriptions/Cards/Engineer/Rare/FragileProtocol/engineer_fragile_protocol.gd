class_name EngineerFragileProtocol
extends HeroUpgrade

@export var _hp_reduction: Array[float] # In %
@export var _shield_power: Array[float]

func apply_card(ctx: CardContext, card_lvl: int) -> void:
	if card_lvl < 1 or card_lvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong card_lvl: ", card_lvl)
		return
	
	var mod_hp := StatModifier.new()
	mod_hp.value = - _hp_reduction[card_lvl - 1] / 100.0
	mod_hp.calc_type = StatModifier.CalcType.MULT
	mod_hp.stat_type = EntityStats.StatType.HEALTH_MAX
	mod_hp.id = "Fragile Protocol"
	ctx.hero.stat_modifiers_registry.register_modifier(mod_hp)
	
	var mod_shield := StatModifier.new()
	mod_shield.value = _shield_power[card_lvl - 1]
	mod_shield.calc_type = StatModifier.CalcType.MULT
	mod_shield.stat_type = EntityStats.StatType.STRENGTH
	mod_shield.action_type = Utils.ActionType.STACK_SHIELD
	mod_shield.id = "Fragile Protocol"
	ctx.hero.stat_modifiers_registry.register_modifier(mod_shield)


func get_description(cardlvl: int) -> String:
	if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[_rarity]:
		printerr("Fragile Protocole: Wrong cardlvl: ", cardlvl)
		return "ERROR"
	
	var hp: String = str(_hp_reduction[cardlvl - 1]).pad_decimals(0)
	var shield_power: String = str(_shield_power[cardlvl - 1]).pad_decimals(0)
	return "Loose " + hp + "% HP MAX. Gain " + shield_power + " shield power."
