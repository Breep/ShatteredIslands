class_name ArdentCelestialDiamondSkin
extends CardEffect

## Ardent Celestial — augmente la résistance du héros aux dégâts magiques.

@export var _magical_resistances: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.M_RESISTANCE
	mod.action_type = Utils.ActionType.DAMAGE_MAGICAL
	mod.calc_type = StatModifier.CalcType.ADD
	mod.tags = [Modifier.TagType.CARD]
	mod.value = _magical_resistances[card_lvl - 1]
	owner.stat_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.M_RESISTANCE, card_name, Utils.ActionType.DAMAGE_MAGICAL)


func get_description(card_lvl: int) -> String:
	return "Le héros gagne " + _value(_magical_resistances[card_lvl - 1]) + " de résistance aux [[MAGICAL_DAMAGE]]."
