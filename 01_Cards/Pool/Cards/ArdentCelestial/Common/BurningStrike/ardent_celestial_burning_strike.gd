class_name ArdentCelestialBurningStrike
extends CardEffect

## Ardent Celestial / Guerrier — à chaque auto-attaque, une chance d'appliquer
## des stacks d'ignite à la cible.

@export var _chance: Array[float]
@export var _ignite_stacks: Array[float]

func apply(ctx: CardContext, card_name: StringName, card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var chance: float = _chance[card_lvl - 1]
	var ignite: float = _ignite_stacks[card_lvl - 1]

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.tags = [Modifier.TagType.CARD]
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		if not cb_vars.has(AutoAttackModifier.VarType.TARGET): return
		var target: Entity = cb_vars[AutoAttackModifier.VarType.TARGET]
		if target == null or not is_instance_valid(target): return
		if not Utils.is_randomize_modifier_active(chance, owner.battle_id): return
		owner.alterations.inflict_condition_stacks(target, ignite, Alteration.Type.IGNITE, card_name)

	owner.battle_callback_registry.register_battle_start(card_name, func() -> void:
		owner.auto_attack_modifier_registry.register_modifier(aa_mod)
	)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.battle_callback_registry.unregister_all(card_name)


func get_description(card_lvl: int) -> String:
	return "À l'attaque, " + str(_chance[card_lvl - 1]) + "% de chance d'appliquer " \
		+ str(_ignite_stacks[card_lvl - 1]) + " [[IGNITE]] à la cible."
