# Carte de prototypage : tous les summons du héros gagnent +1000 PV max.
# Valide la chaîne SummonModifiersRegistry → apply_to → registries actifs des
# summons enfants. Le StatModifier est posé sur le summon_modifiers_registry
# du héros ; au spawn d'un summon, _apply_inherited_summon_modifiers remonte
# la chaîne et clone le modifier dans son stat_modifiers_registry.
class_name CardPrototypingSummonModifier
extends CardEffect

const SUMMON_HP_BONUS: float = 1000.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = SUMMON_HP_BONUS
	mod.stat_type = EntityStats.StatType.HEALTH_MAX
	mod.id = card_name
	owner.summon_modifiers_registry.stat_modifiers_registry.register_modifier(mod)
	
	var aa_mod := AutoAttackModifier.new()
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		var source: Entity = cb_vars.get(AutoAttackModifier.VarType.SOURCE)
		if not is_instance_valid(source): return
		source.alterations.inflict_condition_stacks(target, 10, Alteration.Type.POISON, &"prout")
	owner.summon_modifiers_registry.auto_attack_modifier_registry.register_modifier(aa_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.summon_modifiers_registry.stat_modifiers_registry.remove_modifier(
		EntityStats.StatType.HEALTH_MAX, card_name
	)


func get_description(_card_lvl: int) -> String:
	return "Les summons gagnent +%d PV max." % int(SUMMON_HP_BONUS)
