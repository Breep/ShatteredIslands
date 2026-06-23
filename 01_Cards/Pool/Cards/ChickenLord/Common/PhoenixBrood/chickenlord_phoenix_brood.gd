class_name ChickenLordPhoenixBrood
extends CardEffect

## Chicken Lord / Ardent Celestial — les summons du héros ont une chance
## d'infliger des stacks d'ignite à chaque auto-attaque.
## NOTE: le déblocage « Gifted Celeste » n'est pas géré ici (système d'unlock).

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
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		var source: Entity = cb_vars.get(AutoAttackModifier.VarType.SOURCE)
		if not is_instance_valid(target) or not is_instance_valid(source): return
		if not Utils.is_randomize_modifier_active(chance, source.battle_id): return
		source.alterations.direct_stack(target, ignite, Alteration.Type.IGNITE, card_name)
	owner.summon_modifiers_registry.auto_attack_modifier_registry.register_modifier(aa_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.summon_modifiers_registry.auto_attack_modifier_registry.unregister_modifier(card_name)


func get_description(card_lvl: int) -> String:
	return "[[SUMMON]] : " + _value(_chance[card_lvl - 1]) + "% d'infliger " \
		+ _value(_ignite_stacks[card_lvl - 1]) + " [[IGNITE]] à l'attaque."
