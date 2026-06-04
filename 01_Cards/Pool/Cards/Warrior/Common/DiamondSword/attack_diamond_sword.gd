class_name AttackDiamondSword
extends CardEffect

## Warrior — augmente les dégâts d'attaque (AD) du héros.

@export var _damage: Array[int]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.id = card_name
	mod.stat_type = EntityStats.StatType.AD
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = _damage[card_lvl - 1]
	mod.tags = [StatModifier.TagType.CARD]
	owner.stat_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AD, card_name)


func get_description(card_lvl: int) -> String:
	return "Augmente l'[[AD]] de " + str(_damage[card_lvl - 1]) + "."
