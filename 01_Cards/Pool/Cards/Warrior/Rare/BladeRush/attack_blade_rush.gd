class_name AttackBladeRush
extends CardEffect

## Warrior — au début du combat, augmente l'AD pendant une durée limitée.

@export var _damage_increase: Array[float]
@export var _duration: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var damage: float = _damage_increase[card_lvl - 1]
	var duration: float = _duration[card_lvl - 1]

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		var mod := StatModifier.new()
		mod.id = card_name
		mod.stat_type = EntityStats.StatType.AD
		mod.calc_type = StatModifier.CalcType.ADD
		mod.value = damage
		mod.tags = [Modifier.TagType.CARD]
		owner.stat_modifiers_registry.register_modifier(mod)

		owner.battle_callback_registry.register_oneshot(duration, func() -> void:
			owner.stat_modifiers_registry.remove_modifier(EntityStats.StatType.AD, card_name)
		, card_name)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "Début de combat : +" + _value(_damage_increase[card_lvl - 1]) + " [[AD]]" \
		+ " pendant " + _value(_duration[card_lvl - 1]) + "s."
