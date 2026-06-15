class_name SE_WolfRendingBite
extends SkillEffect

# Silver partagé des loups "Morsure Lacérante" : toutes les _attack_period auto-attaques,
# la morsure inflige _vulnerability_stacks de Vulnerability et _weakness_stacks de Weakness
# à la cible (compteur par instance via AutoAttackModifier).

@export var _attack_period: int = 4
@export var _vulnerability_stacks: float = 3.0
@export var _weakness_stacks: float = 3.0


func apply(ctx: SkillContext) -> void:
	var wolf: Entity = ctx.entity
	if wolf == null:
		Verbose.error("SE_WolfRendingBite: null owner", Verbose.Category.ENTITY_MODULE)
		return

	# Boxed pour vivre par instance (la resource SkillEffect peut être partagée).
	var count: Array[int] = [0]
	var aa_mod := AutoAttackModifier.new()
	aa_mod.id = &"WolfRendingBite"
	aa_mod.is_one_time_effect = false
	aa_mod.additional_effect_callback = func(data: Dictionary) -> void:
		var source: Entity = data.get(AutoAttackModifier.VarType.SOURCE)
		var target: Entity = data.get(AutoAttackModifier.VarType.TARGET)
		if not is_instance_valid(source) or not is_instance_valid(target):
			return
		count[0] += 1
		if count[0] < _attack_period:
			return
		count[0] = 0
		source.alterations.inflict_condition_stacks(
			target, _vulnerability_stacks, Alteration.Type.VULNERABILITY, &"WolfRendingBiteVuln")
		source.alterations.inflict_condition_stacks(
			target, _weakness_stacks, Alteration.Type.WEAKNESS, &"WolfRendingBiteWeak")
	wolf.auto_attack_modifier_registry.register_modifier(aa_mod)


func get_description() -> String:
	return "Toutes les " + _value(_attack_period) + " attaques, inflige " \
		+ _value(_vulnerability_stacks) + " [[VULNERABILITY]] et " + _value(_weakness_stacks) \
		+ " [[WEAKNESS]] à la cible."
