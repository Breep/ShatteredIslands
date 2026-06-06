# Carte de prototypage : tous les acolytes du héros gagnent +40 AD et un
# effet de poison à l'attaque. Valide la chaîne AcolyteModifiersRegistry →
# apply_to → registries actifs des acolytes. Les modifiers sont posés sur
# l'acolyte_modifiers_registry du héros ; au spawn d'un acolyte,
# _apply_inherited_acolyte_modifiers remonte la chaîne summoner et clone les
# modifiers dans les registries actifs de l'acolyte.
class_name CardPrototypingAcolyteModifier
extends CardEffect

const ACOLYTE_AD_BONUS: float = 40.0
const POISON_STACKS_ON_HIT: float = 10.0


func apply(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	var owner: Entity = ctx.entity_owner
	var mod := StatModifier.new()
	mod.calc_type = StatModifier.CalcType.ADD
	mod.value = ACOLYTE_AD_BONUS
	mod.stat_type = EntityStats.StatType.AD
	mod.id = card_name
	owner.acolyte_modifiers_registry.stat_modifiers_registry.register_modifier(mod)

	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = card_name
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(cb_vars: Dictionary) -> void:
		var target: Entity = cb_vars.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(target): return
		var source: Entity = cb_vars.get(AutoAttackModifier.VarType.SOURCE)
		if not is_instance_valid(source): return
		source.alterations.inflict_condition_stacks(target, POISON_STACKS_ON_HIT, Alteration.Type.POISON, card_name)
	owner.acolyte_modifiers_registry.auto_attack_modifier_registry.register_modifier(aa_mod)


func revert(ctx: CardContext, card_name: StringName, _card_lvl: int) -> void:
	ctx.entity_owner.acolyte_modifiers_registry.stat_modifiers_registry.remove_modifier(
		EntityStats.StatType.AD, card_name
	)
	ctx.entity_owner.acolyte_modifiers_registry.auto_attack_modifier_registry.unregister_modifier(card_name)


func get_description(_card_lvl: int) -> String:
	return "Les acolytes gagnent +%d AD et infligent %d [[POISON]] à l'attaque." % [
		int(ACOLYTE_AD_BONUS), int(POISON_STACKS_ON_HIT)
	]
