class_name AttackAdaptiveTactics
extends CardEffect

## Warrior — bonus adapté au type d'auto-attaque du héros :
## héros à distance → +portée ; héros au corps-à-corps → +vol de vie.

@export var _range_bonus: Array[float]
@export var _lifesteal_bonus: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.id = card_name
	mod.calc_type = StatModifier.CalcType.ADD
	mod.tags = [StatModifier.TagType.CARD]
	if owner.stats.auto_attack_type == EntityStats.AutoAttackType.RANGED:
		mod.stat_type = EntityStats.StatType.AR
		mod.value = _range_bonus[card_lvl - 1]
	else:
		mod.stat_type = EntityStats.StatType.LIFESTEAL
		mod.value = _lifesteal_bonus[card_lvl - 1]
	owner.stat_modifiers_registry.register_modifier(mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	if owner.stats.auto_attack_type == EntityStats.AutoAttackType.RANGED:
		owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AR, card_name)
	else:
		owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.LIFESTEAL, card_name)


func get_description(card_lvl: int) -> String:
	return "Héros Distance: +" + str(_range_bonus[card_lvl - 1]) + " portée\n" \
		+ "Héros Mêlée: +" + str(_lifesteal_bonus[card_lvl - 1]) + "% vol de vie"
